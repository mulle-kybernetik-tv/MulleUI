#import "import.h"

#import <mulle-container/mulle-container.h>
#import "CGGeometry.h"


@class CALayer;
@class CGContext;
@class UIWindow;
@class MulleImageLayer;

//
// the main layer which is bottom-most defines the geometry
// the UIView must have a mainLayer which is responsible for the "background"
// other layers are composited on top of it
// Then the subviews are drawn/composited on those (these are scaled and 
// transformed)
//
@interface UIView : NSObject 
{
   UIView                      *_superview;
   CALayer                     *_mainLayer;

   struct mulle_pointerarray   *_layers;
   struct mulle_pointerarray   *_subviews;

   MulleImageLayer             *_cacheLayer;  // same size as _mainLayer (contains all layers and subviews ?)
}

@property BOOL clipsSubviews;
@property BOOL needsLayout;
@property BOOL needsCaching;

- (void) setNeedsLayout;
- (void) setNeedsCaching;  // wipes the _cacheLayer and asks for a new one to be drawn

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

// - (CALayer *) mainLayer;  // mainlayer is an internal thing

//
// You do not need not to call super in UIView subclasses, if you manually
// layout everything
// 
- (void) layoutSubviews;

@end
