//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MullePopUpButton.h"

#import "import-private.h"

#import "UIColor.h"
#import "CAShapeLayer.h"

#define DISCLOSURE_WIDTH  24.0

@implementation MullePopUpButton

#define T_MARGIN   5
#define L_MARGIN   1
#define B_MARGIN   7
#define R_MARGIN   10

- (CGRect) mulleInsetDisclosureTriangleWithFrame:(CGRect) frame
{
   UIEdgeInsets   insets;
   double         borderWidth;

   borderWidth = [_titleBackgroundLayer borderWidth];
   insets      = UIEdgeInsetsMake( borderWidth / 2 + T_MARGIN, 
                                   borderWidth / 2 + L_MARGIN, 
                                   borderWidth / 2 + B_MARGIN,
                                   borderWidth / 2 + R_MARGIN);

   return( UIEdgeInsetsInsetRect( frame, insets));
}


/* Selection and highlight colors are currently hardcoded in 
 * UIButton+UIResponder.
 */
- (CALayer *) mulleDisclosureLayerWithFrame:(CGRect) frame
{
   CAShapeLayer   *layer;
   CGPath         *path;
   UIEdgeInsets    insets;
   CGRect          rect;

   layer = [CAShapeLayer layerWithFrame:frame];
   
   path  = CGPathCreate( MulleObjCInstanceGetAllocator( self));

   rect.origin      = frame.origin;
   rect.size.width  = DISCLOSURE_WIDTH; 
   rect.size.height = frame.size.height;

   rect = [self mulleInsetDisclosureTriangleWithFrame:rect]; 

   CGPathMoveToPoint( path, NULL, CGRectGetMinX( rect), rect.origin.y);
   CGPathAddLineToPoint( path, NULL, CGRectGetMidX( rect), 
                                     rect.origin.y + rect.size.height);
   CGPathAddLineToPoint( path, NULL, CGRectGetMaxX( rect), 
                                     rect.origin.y);
   CGPathCloseSubpath( path);

   [layer setPath:path];
   // now path is owned by layer

   // copy properties from titleBackgroundLayer
   // [layer setBorderWidth:[_titleBackgroundLayer borderWidth]];
   // [layer setBorderColor:[_titleBackgroundLayer borderColor]];
   // [layer setCornerRadius:[_titleBackgroundLayer cornerRadius]];

   [layer setStrokeColor:[_titleBackgroundLayer borderColor]];
   [layer setFillColor:getNVGColor( 0x3F1F1FFF)];

   [layer setCStringName:"UIButton disclosureLayer"];
   return( layer);
}


- (void) setupLayersWithFrame:(CGRect) frame
{
   CGRect   rect;

   [super setupLayersWithFrame:frame];

   rect.origin.x    = CGRectGetMaxX( frame) - DISCLOSURE_WIDTH;
   rect.origin.y    = frame.origin.y;
   rect.size.width  = DISCLOSURE_WIDTH;
   rect.size.height = frame.size.height;
   _disclosureLayer = [self mulleDisclosureLayerWithFrame:frame];
  
   [self addLayer:_disclosureLayer];
}



- (CGRect) mulleInsetTextLayerFrameWithFrame:(CGRect) frame
{
   CGRect   rect;

   rect = [super mulleInsetTextLayerFrameWithFrame:frame];
   rect.size.width -= DISCLOSURE_WIDTH / 2.0;
   return( rect);
}


- (void) layoutLayersWithFrame:(CGRect) frame
{
   [super layoutLayersWithFrame:frame];

   frame.origin.x   = CGRectGetMaxX( frame) - DISCLOSURE_WIDTH;
   frame.size.width = DISCLOSURE_WIDTH;
   [_disclosureLayer setFrame:frame];
}

- (void) setTitlesCStrings:(char **) titles 
                     count:(NSUInteger) count
{
   _titles      = titles;
   _titlesCount = count;
}

@end
