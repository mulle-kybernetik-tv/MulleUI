#import "import.h"

#import <mulle-container/mulle-container.h>
#import "CGGeometry.h"


@class CALayer;
@class CGContext;
@class UIWindow;


//
// the main layer which is bottom most defines the geometry
//
@interface UIView : NSObject 
{
   UIView                      *_superview;
   CALayer                     *_mainLayer;

   struct mulle_pointerarray   *_subviews;
   struct mulle_pointerarray   *_layers;
}

@property BOOL clipsSubviews;

- (id) initWithFrame:(CGRect) frame;
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

@end
