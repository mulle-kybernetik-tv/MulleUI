//
//  PSTCollectionViewCell.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionView.h"

#import "UIView+Yoga.h"
#import "UIView+NSArray.h"
#import "UIControl.h"
#import "CALayer.h"


@implementation PSTCollectionViewExt
@end


@implementation PSTCollectionReusableView

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void) prepareForReuse 
{
   [_layoutAttributes autorelease];
   _layoutAttributes = nil;
}

- (void) applyLayoutAttributes:(PSTCollectionViewLayoutAttributes *) layoutAttributes 
{
    if (layoutAttributes != _layoutAttributes) {
        _layoutAttributes = layoutAttributes;

        [self setBounds:(CGRect){.origin = [self bounds].origin, .size = [layoutAttributes size]}];
        [self setFrame:[layoutAttributes frame]];
        [self setHidden:[layoutAttributes isHidden]];
//        self.layer.transform = layoutAttributes.transform3D;
        //self.layer.zPosition = layoutAttributes.zIndex;
        [[self layer] setOpacity:[layoutAttributes alpha]];
    }
}

- (void)willTransitionFromLayout:(PSTCollectionViewLayout *)oldLayout toLayout:(PSTCollectionViewLayout *)newLayout {
    _reusableViewFlags.inUpdateAnimation = YES;
}

- (void)didTransitionFromLayout:(PSTCollectionViewLayout *)oldLayout toLayout:(PSTCollectionViewLayout *)newLayout {
    _reusableViewFlags.inUpdateAnimation = NO;
}

- (BOOL)isInUpdateAnimation {
    return _reusableViewFlags.inUpdateAnimation;
}

- (void)setInUpdateAnimation:(BOOL)inUpdateAnimation {
    _reusableViewFlags.inUpdateAnimation = (unsigned int)inUpdateAnimation;
}

- (NSComparisonResult) compare:(id) other
{
   CGFloat z1 = [[self layoutAttributes] zIndex];
   CGFloat z2 = [[other layoutAttributes] zIndex];
   if (z1 > z2) 
      return NSOrderedDescending;
   if (z1 < z2) 
      return NSOrderedAscending;
   return NSOrderedSame;
}

@end


@implementation PSTCollectionViewCell 
///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _backgroundView = [[UIView alloc] initWithFrame:[self bounds]];
        [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:_backgroundView];

        _contentView = [[UIView alloc] initWithFrame:[self bounds]];
        [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:_contentView];

        // _menuGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(menuGesture:)];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)prepareForReuse {
    [_layoutAttributes autorelease];
    _layoutAttributes = nil;
    _selected = NO;
    _highlighted = NO;
//    _accessibilityTraits = UIAccessibilityTraitNone;
}

// Selection highlights underlying contents
- (void)setSelected:(BOOL)selected {
    _collectionCellFlags.selected = (unsigned int)selected;
    // self.accessibilityTraits = selected ? UIAccessibilityTraitSelected : UIAccessibilityTraitNone;
    [self updateBackgroundView:selected];
}

// Cell highlighting only highlights the cell itself
- (void)setHighlighted:(BOOL)highlighted {
    _collectionCellFlags.highlighted = (unsigned int)highlighted;
    [self updateBackgroundView:highlighted];
}

- (void)updateBackgroundView:(BOOL)highlight {
    [_selectedBackgroundView setAlpha:highlight ? 1.0f : 0.0f];
    [self setHighlighted:highlight forViews:[[self contentView] subviews]];
}

- (void)setHighlighted:(BOOL)highlighted forViews:(id)subviews 
{
   UIView   *view;

   for( view in subviews) {
        // Ignore the events if view wants to
        if (![view isUserInteractionEnabled] &&
             [view respondsToSelector:@selector(setHighlighted:)] &&
            ![view conformsToProtocol:@protocol( UIControl)]) {
            [(PSTCollectionViewCell *) view setHighlighted:highlighted];

            [self setHighlighted:highlighted forViews:[view subviews]];
        }
    }
}

//- (void)menuGesture:(UILongPressGestureRecognizer *)recognizer {
//    NSLog(@"Not yet implemented: %@", NSStringFromSelector(_cmd));
//}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_backgroundView != backgroundView) {
        [_backgroundView removeFromSuperview];
        _backgroundView = backgroundView;
        [_backgroundView setFrame:[self bounds]];
        [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self insertSubview:_backgroundView atIndex:0];
    }
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView {
    if (_selectedBackgroundView != selectedBackgroundView) {
        [_selectedBackgroundView removeFromSuperview];
        _selectedBackgroundView = selectedBackgroundView;
        [_selectedBackgroundView setFrame:[self bounds]];
        [_selectedBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_selectedBackgroundView setAlpha:[self isSelected] ? 1.0f : 0.0f];
        if (_backgroundView) {
            [self insertSubview:_selectedBackgroundView aboveSubview:_backgroundView];
        }
        else {
            [self insertSubview:_selectedBackgroundView atIndex:0];
        }
    }
}

- (BOOL)isSelected {
    return _collectionCellFlags.selected;
}

- (BOOL)isHighlighted {
    return _collectionCellFlags.highlighted;
}

- (void)performSelectionSegue {
    /*
        Currently there's no "official" way to trigger a storyboard segue
        using UIStoryboardSegueTemplate, so we're doing it in a semi-legal way.
     */
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"per%@", @"form:"]);
    if ([self->_selectionSegueTemplate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self->_selectionSegueTemplate performSelector:selector withObject:self];
#pragma clang diagnostic pop
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollection/UICollection interoperability

#ifdef kPSUIInteroperabilityEnabled
#import <objc/runtime.h>
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *sig = [super methodSignatureForSelector:selector];
    if(!sig) {
        NSString * selString = NSStringFromSelector(selector);
        if ([selString hasPrefix:@"_"]) {
            SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
            sig = [super methodSignatureForSelector:cleanedSelector];
        }
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv {
    NSString * selString = NSStringFromSelector([inv selector]);
    if ([selString hasPrefix:@"_"]) {
        SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
        if ([self respondsToSelector:cleanedSelector]) {
            inv.selector = cleanedSelector;
            [inv invokeWithTarget:self];
        }
    }else {
        [super forwardInvocation:inv];
    }
}
#endif

@end
