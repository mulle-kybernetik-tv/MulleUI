#import "UILabel.h"

#import "UIWindow.h"
#import "MulleTextLayer.h"
#import "CGFont.h"
#import "UIColor.h"
#import "UIFont.h"


@implementation UILabel : UIView


+ (Class) layerClass
{
   return( [MulleTextLayer class]);
}


- (CGFloat) fontSize
{
   MulleTextLayer  *layer;
   CGFloat         pixelsize;
   CGFloat         ppi;

   layer     = (MulleTextLayer *) _mainLayer;
   ppi       = [self pixelsPerInchOfPrimaryMonitor];
   pixelsize = [layer fontPixelSize];
   return( pixelsize * 72.0 / ppi);
}


- (void) setFontSize:(CGFloat) points
{
   MulleTextLayer  *layer;
   CGFloat         ppi;

   layer  = (MulleTextLayer *) _mainLayer;
   ppi    = [self pixelsPerInchOfPrimaryMonitor];
   // pixel per inch, points are 1/72 inch
   [layer setFontPixelSize:points * ppi / 72.0];
}


- (void) setFont:(UIFont *) font
{
   CGFloat         ppi;
   MulleTextLayer  *layer;

   layer  = (MulleTextLayer *) _mainLayer;
   [layer setFontName:[font fontName]];
   // TODO: figure out pointSize vs pixelSize
   ppi = [self pixelsPerInchOfPrimaryMonitor];
   [layer setFontPixelSize:[font pointSize] / 72.0 * ppi];
}


- (UIFont *) font
{
   // TODO: figure out pointSize vs pixelSize
   return( [UIFont fontWithNameCString:[self fontName]
                                  size:[self fontPixelSize]]);
}


- (void *) forward:(void *) param
{
   switch( _cmd)
   {
   case @selector( textAlignment)     : _cmd = @selector( alignmentMode); break;
   case @selector( setTextAlignment:) : _cmd = @selector( setAlignmentMode:); break;
   }
   return( mulle_objc_object_call_variablemethodid_inline( _mainLayer,
                                                    (mulle_objc_methodid_t) _cmd,
                                                    param));
}

@end

