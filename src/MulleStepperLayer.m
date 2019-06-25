#import "MulleStepperLayer.h"

#import "CGContext.h"
#import "CGFont.h"


@implementation MulleStepperLayer : CALayer


- (void) drawContentsInContext:(CGContext *) context
{
   CGFloat             fontSize;
   CGFloat             midX;
   CGFloat             strokeWidth;
   CGFont              *font;
   CGRect              frame;
   CGRect              frame1;
   CGRect              frame2;
   char                *name;
   struct NVGcontext   *vg;

   vg    = [context nvgContext];
   frame = [self frame];

   strokeWidth = 2.0;

   // calculate two inner frames without surrounding box/border/divider
   frame1.origin.x    = frame.origin.x + strokeWidth;
   frame1.origin.y    = frame.origin.y + strokeWidth;
   frame1.size.width  = (frame.size.width - strokeWidth) / 2.0 - strokeWidth;
   frame1.size.height = frame.size.height - strokeWidth * 2;;

   frame2 = frame1;
   frame2.origin.x    = frame1.origin.x + frame1.size.width + strokeWidth;

   // draw surrounding box and the divider
   nvgBeginPath( vg);
   nvgRoundedRect( vg, frame.origin.x, 
                       frame.origin.y, 
                       frame.size.width - strokeWidth, 
                       frame.size.height - strokeWidth, 
                       2.0);

   midX = frame2.origin.x - strokeWidth / 2.0;
   nvgMoveTo( vg, midX, frame.origin.y);
   nvgLineTo( vg, midX, frame.origin.y + frame.size.height - 1.0);
   nvgStrokeColor( vg, nvgRGBA(255,127,127,255));
   nvgStrokeWidth( vg, (int) strokeWidth);
   nvgStroke( vg);

   // draw two text labels in each side

   font = [context fontWithName:_fontName ? _fontName : "sans"];
   name = [font name];  // get actual name, which could have different address

   fontSize = [self fontSize];
   if( fontSize == 0.0)
      fontSize = 20.0;

	nvgFontSize( vg, fontSize);
	nvgFontFace( vg, name);
	nvgFillColor( vg, nvgRGBA(255,255,255,255)); // TODO: use textColor

	nvgTextAlign( vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE);
	nvgText( vg, frame1.origin.x + frame1.size.width / 2.0, frame1.origin.y + frame1.size.height *0.5f, "-", NULL);
	nvgText( vg, frame2.origin.x + frame2.size.width / 2.0, frame2.origin.y + frame2.size.height *0.5f, "+", NULL);
}

@end
