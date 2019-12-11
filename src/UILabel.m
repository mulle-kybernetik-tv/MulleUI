#import "UILabel.h"

#import "UIWindow.h"
#import "MulleTextLayer.h"
#import "CGFont.h"


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

   layer     = (MulleTextLayer *) _mainLayer;
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


- (void) setFontSize:(CGFloat) points
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

@end

