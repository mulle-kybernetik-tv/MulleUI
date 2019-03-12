#import "import.h"

#import <mulle-container/mulle-container.h>
#import "CGGeometry.h"
#import "YogaProtocol.h"


@class CALayer;
@class CGContext;
@class UIWindow;


//
// the main layer which is bottom-most defines the geometry
// the UIView must have a mainLayer which is responsible for the "background"
// other layers are composited on top of it
// Then the subviews are drawn/composited on those (these are scaled and 
// transformed)
//
@interface UIView : NSObject < Yoga >
{
   UIView                      *_superview;
   CALayer                     *_mainLayer;

   struct mulle_pointerarray   *_layers;
   struct mulle_pointerarray   *_subviews;

   // ivars for Yoga
   id <NSArray,NSFastEnumeration>   *_subviewsArrayProxy;
   YGLayout                         *_yoga;
   BOOL                             _isYogaEnabled;
}

@property BOOL clipsSubviews;
@property BOOL needsLayout;

- (void) setNeedsLayout;


+ (Class) layerClass;

- (id) initWithFrame:(CGRect) frame;

// designated initializer
- (id) initWithLayer:(CALayer *) layer;

- (void) addLayer:(CALayer *) layer;
- (void) addSubview:(UIView *) layer;

- (CGRect) bounds;
- (void) setBounds:(CGRect) rect;
- (CGRect) frame;
- (void) setFrame:(CGRect) rect;

- (void) renderWithContext:(CGContext *) context;

- (NSInteger) getLayers:(CALayer **) buf
                 length:(NSUInteger) length;
- (NSInteger) getSubviews:(UIView **) buf
                   length:(NSUInteger) length;           

- (UIWindow *) window;
- (UIView *) superview;

- (CGRect) clipRect;

- (CALayer *) mainLayer;

- (CGSize) sizeThatFits:(CGSize) size;

//
// You do not need not to call super in UIView subclasses, if you manually
// layout everything
// 
- (void) layoutSubviews;

@end
