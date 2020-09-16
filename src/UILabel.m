#import "UILabel.h"

#import "UIWindow.h"
#import "MulleTextLayer.h"
#import "CGFont.h"
#import "UIColor.h"
#import "UIFont.h"


@implementation UILabel : UIView

- (id) initWithFrame:(CGRect) frame
{
   MulleTextLayer  *textLayer;

   textLayer = [[[MulleTextLayer alloc] initWithFrame:frame] autorelease];
   return( [self initWithLayer:textLayer]);
}


- (void) setCStringName:(char *) s
{
   // ignore
}

- (CGFloat) fontSize
{
   MulleTextLayer  *layer;
   CGFloat         pixelsize;
   CGFloat         ppi;
   UIWindow        *window;

   layer  = (MulleTextLayer *) _mainLayer;
   window = [self window];
   if( window)
      ppi = [window primaryMonitorPPI];
   else
      ppi = [UIWindow primaryMonitorPPI];   
   if( ! ppi)
      ppi = 100;
   pixelsize = [layer fontPixelSize];
   return( pixelsize * 72.0 / ppi);
}


- (void) setFontPixelSize:(CGFloat) points
{
   MulleTextLayer  *layer;
   CGFloat         ppi;
   UIWindow        *window;

   layer  = (MulleTextLayer *) _mainLayer;
   window = [self window];
   if( window)
      ppi = [window primaryMonitorPPI];
   else
      ppi = [UIWindow primaryMonitorPPI];
   if( ! ppi)
      ppi = 100;
   [layer setFontPixelSize:points * ppi / 72.0];
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


- (void) setFont:(UIFont *) font
{
   [self setFontName:[font fontName]];
   // TODO: figure out pointSize vs pixelSize
   [self setFontPixelSize:[font pointSize]];
}

- (UIFont *) font
{
   // TODO: figure out pointSize vs pixelSize
   return( [UIFont fontWithNameCString:[self fontName]
                                  size:[self fontPixelSize]]);
}

@end

