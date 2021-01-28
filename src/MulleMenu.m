//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleMenu.h"

#import "import-private.h"

#import "UIScrollView.h"
#import "UIStackView.h"
#import "MulleMenuButton.h"
#import "CGGeometry+CString.h"

// TODO:
// put into menuplane
// menuplane should intercept other events
// tooltips of menus go where ?
// Menu needs an anchor point/anchor view
// Need to really hide scrollview indicator views, so they don't grab events
// if invisble.
// Possibly allow tweaking of scrollindicator offsets.
// Scrollweel support for scrolling up/down (currently only zoom). Possibly
// use zoom with SHIFT by default ?

@implementation MulleMenu

- (instancetype) initWithLayer:(CALayer *) layer
{
   CGRect   frame;
   CGSize   size;

   self         = [super initWithLayer:layer];
   frame.origin = CGPointZero;
   frame.size   = [layer frame].size;

   _stackView  = [UIStackView mulleViewWithFrame:frame];
   [_stackView setAxis:UILayoutConstraintAxisVertical];
   [_stackView setDistribution:MulleStackViewDistributionUnbounded];

   _scrollView = [UIScrollView mulleViewWithFrame:frame];
   [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [_scrollView setShowsHorizontalScrollIndicator:NO];
   [[_scrollView contentView] addSubview:_stackView];

   frame.size.height = 1000000.0;
   [_scrollView setContentSize:frame.size];

   [self addSubview:_scrollView];

   return( self);
}


- (void) addMenuButton:(MulleMenuButton *) button;
{
   [_stackView addSubview:button];
}


// Our layouting scheme is strictly top/down. So the parentview allots space
// for the stackview to size itself. (In our case this is infinite along the
// vertical axis). Once this is done, regular layouting commences and the
// stackview layouts itself.
//
// Now afterwards we can collect what has been done, wrap it into a
// scrollview or shrink it appropriately. The main problem is that we should
// also shrink. So its like bottom up layouting.. The bottom up layouting
// may not expand outside of the alloted space given in top down. If a view
// refused to fit, it can get wrapped into a scrollview (automatically ?) or
// be discard/truncated ?
//
- (void) layoutSubview:(UIView *) view
              inBounds:(CGRect) bounds
      autoresizingMask:(UIViewAutoresizing) autoresizingMask
{
   // increase size for top/down layout, later in -layout
   // shrink size to fit
   if( view == _scrollView)
   {
      bounds.size.height = 1000000.0; // large...
      [_scrollView setContentSize:bounds.size];
   }

   [super layoutSubview:view
               inBounds:bounds
       autoresizingMask:autoresizingMask];
}


- (void) layout
{
   CGSize   size;
   CGRect   frame;
   CGRect   before;
   UIView   *contentView;

   [super layout];

   assert( _stackView);

   // shrink stackView to fit
   frame.origin = CGPointZero;
   frame.size   = [_stackView sizeThatFits:[self bounds].size];
   [_stackView setFrame:frame];

   assert( _scrollView);

   [_scrollView setContentSize:frame.size];

   // this should be done by the scrollview. Is it necessary to use
   // a separate property for contentSize, if we could use the bounds
   // of the contentView as storage ?

   contentView  = [_scrollView contentView];
   frame.origin = [contentView frame].origin;
   [contentView setFrame:frame];

   // so scrollview can set indicator views
   [_scrollView layoutSubviews];

   // shrink self to fit if frame.size.height is less than current
   before = [self frame];
   if( before.size.height > frame.size.height)
   {
      frame.origin = before.origin;
      [self setFrame:frame];
   }
}


- (void) addMenuButtonsWithTitleCStrings:(char **) titles
                                   count:(NSUInteger) n
                                  target:(id) target
                                  window:(UIWindow *) window
{
   NSUInteger        i;
   MulleMenuButton   *menuButton;

   for( i = 0; i < n; i++)
   {
      menuButton = [MulleMenuButton mulleViewWithFrame:CGRectMake( 0, 0, 0, 20)];
      [menuButton setTitleCString:titles[ i]];
      [menuButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
      [menuButton setTarget:target];
      [menuButton setAction:@selector( menuButtonClicked:)];

      /* TODO: Tricky, if the button resizes then the tracking area must also
               resize. BUT, it's not really dynamic yet.
       */
      [menuButton addTrackingAreaWithRect:CGRectMake( 0, 0, 200, 20)
                                 toWindow:window
                                 userInfo:nil];
      [self addMenuButton:menuButton];
   }
}

@end
