#import "import.h"

#import <mulle-container/mulle-container.h>
#import "CGGeometry.h"
#import "YogaProtocol.h"
#import "CATime.h"
#import "CGColor.h"
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
struct MulleClickDragDifferentiator
{
   CARelativeTime   _mouseMotionSuppressionDelay;  // config value

   CAAbsoluteTime   _suppressUntilTimestamp; 
};

typedef enum UIViewAutoresizing
{   
   UIViewAutoresizingNone                 = 0x00,
   UIViewAutoresizingFlexibleTopMargin    = 0x01,
   UIViewAutoresizingFlexibleBottomMargin = 0x02,
   UIViewAutoresizingFlexibleLeftMargin   = 0x04,
   UIViewAutoresizingFlexibleRightMargin  = 0x08,
   UIViewAutoresizingFlexibleWidth        = 0x10,
   UIViewAutoresizingFlexibleHeight       = 0x20
} UIViewAutoresizing;


enum UILayoutStrategy
{
   UILayoutStrategyDefault,
   UILayoutStrategyContinue,
   UILayoutStrategyStop
};


@interface UIView : NSObject < Yoga>
{
   UIView                      *_superview;
   CALayer                     *_mainLayer;

   struct mulle_pointerarray   *_layers;     // todo why no inline ?
   struct mulle_pointerarray   *_subviews;

   // ivars for Yoga
   id <NSArray,NSFastEnumeration>   _subviewsArrayProxy;
   YGLayout                         *_yoga;
   
   struct MulleTrackingAreaArray    _trackingAreas;

   MulleImageLayer                  *_cacheLayer; 

   struct MulleClickDragDifferentiator  _clickOrDrag;
}

@property( getter=isHidden)                 BOOL   hidden;
@property( getter=isUserInteractionEnabled) BOOL   userInteractionEnabled;

@property BOOL   clipsSubviews;
@property BOOL   needsLayout;   // use setNeedsLayout for marking
@property BOOL   needsCaching;
@property BOOL   needsDisplay;  // a NOP for compatiblity
                 
@property CGFloat   alpha;
@property enum UIViewAutoresizing   autoresizingMask; 

- (void) setNeedsLayout;    // use this to touch up all hierarchy
- (void) setNeedsDisplay;
- (void) setNeedsCaching;  // wipes the _cacheLayer and asks for a new one to be drawn

- (void) _setNeedsLayout; 

+ (Class) layerClass;

- (instancetype) initWithFrame:(CGRect) frame;

// designated initializer
- (instancetype) initWithLayer:(CALayer *) layer;

- (void) mulleAddRetainedLayer:(CALayer *) layer;
- (void) mulleAddRetainedSubview:(UIView *) layer;

- (void) addLayer:(CALayer *) layer;
- (void) addSubview:(UIView *) layer;

- (CALayer *) layer;

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

- (CGSize) sizeThatFits:(CGSize) size;

//
// You do not need not to call super in UIView subclasses, if you manually
// layout everything
// 
//- (void) layoutSubviews;

- (void) startLayoutWithFrameInfo:(struct MulleFrameInfo *) info;
- (void) layout;
- (void) layoutIfNeeded;
- (void) endLayout;

// yoga uses this to its layout
- (enum UILayoutStrategy) layoutStrategy;

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


@interface UIView( CALayerForwarding)

// methods forward to CALayer (mainLayer)
//
// bounds define the paint transformation for layers only
// subviews are not affected
//
- (CGRect) bounds;
- (void) setBounds:(CGRect) rect;
- (CGRect) frame;
- (void) setFrame:(CGRect) rect;

- (void) setBackgroundColor:(CGColorRef) color;
- (void) setBorderColor:(CGColorRef) color;
- (void) setBorderWidth:(CGFloat) value;
- (void) setCornerRadius:(CGFloat) color;
- (CGColorRef) backgroundColor;
- (CGColorRef) borderColor;
- (CGFloat) borderWidth;
- (CGFloat) cornerRadius;
- (char *) cStringName;
- (void) setCStringName:(char *) s;

@end


// didn't want those exposed I guess.
@interface UIView( Internals)

- (struct mulle_pointerarray *) _layers;
- (struct mulle_pointerarray *) _subviews; 

@end
