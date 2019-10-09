#import "import.h"

#import <mulle-container/mulle-container.h>
#import "CGGeometry.h"
#import "CATime.h"
#import "MulleTrackingArea.h"


@class CALayer;
@class CGContext;
@class UIWindow;
@class MulleImageLayer;

struct MulleFrameInfo;

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

   struct mulle_pointerarray   *_layers;     // todo why no inline ?
   struct mulle_pointerarray   *_subviews;

   struct MulleTrackingAreaArray  _trackingAreas;

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

- (CALayer *) layer;

- (CGRect) bounds;
- (void) setBounds:(CGRect) rect;
- (CGRect) frame;
- (void) setFrame:(CGRect) rect;

- (void) renderWithContext:(CGContext *) context;
- (void) animateWithAbsoluteTime:(CAAbsoluteTime) renderTime;

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


- (void) updateRenderCachesWithContext:(CGContext *) context
                             frameInfo:(struct MulleFrameInfo *) info;
                             
// view must be part of window view hierarchy, for these function to work
// properly
- (struct MulleTrackingArea *) addTrackingAreaWithRect:(CGRect) rect
                                              userInfo:(id) userInfo;
- (void) removeTrackingArea:(struct MulleTrackingArea *) trackingRect;
- (NSUInteger) numberOfTrackingAreas;
- (struct MulleTrackingArea *) trackingAreaAtIndex:(NSUInteger) i;

@end
