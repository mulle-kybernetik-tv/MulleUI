#import "MulleSliderLayer.h"

#import "CGContext.h"
#import "CGFont.h"

@implementation MulleSliderLayer : CALayer

- (instancetype) initWithFrame:(CGRect) frame
{
   self = [super initWithFrame:frame];
   if( self)
      self->_maximumValue = 1.0;
   return( self);      
}


- (void) setValue:(float) value
{
   if( value > _maximumValue)
      value = _maximumValue;
   if( value < _minimumValue)
      value = _minimumValue;
 
   _value = value; // use property setter to get future goodness ??
}


- (void) setMinimumValue:(float) value
{
   _minimumValue = value; // use property setter to get future goodness ??

   if( value > _maximumValue)
      _maximumValue = value;
   if( value > _value)
      _value = value;
}


- (void) setMaximumValue:(float) value
{
   _maximumValue = value; // use property setter to get future goodness ??

   if( value < _minimumValue)
      _minimumValue = value;
   if( value < _value)
      _value = value;
}


- (void) drawContentsInContext:(CGContext *) context
{
   CGRect              frame;
   NVGpaint            bg;
	NVGpaint            knob;
   struct NVGcontext   *vg;
   float               normalized;
	float               cy;   // relative vertical position (0.25 is first quarter, 0.5 is center)
	float               kr;   // knob radius 
   float               pos;  // knob position from 0.0 to 1.0 

   pos        = 0.0;
   normalized = [self maximumValue] - [self minimumValue];
   if( normalized > 0.0)
      pos = [self value] / normalized;

   // stupido protection
   assert( pos >= 0.0 && pos <= 1.0);

   vg    = [context nvgContext];
   frame = [self frame];

	cy = frame.origin.y+(int)(frame.size.height*0.5f);
   // knob radius 
	kr = (int)(frame.size.height*0.15f);
   // slider position from 0.0 to 1.0 

	nvgSave(vg);
//	nvgClearState(vg);

	// Slot
	bg = nvgBoxGradient(vg, frame.origin.x,cy-2+1, frame.size.width,4, 2,2, nvgRGBA(0,0,0,32), nvgRGBA(0,0,0,128));
	nvgBeginPath(vg);
	nvgRoundedRect(vg, frame.origin.x,cy-2, frame.size.width,4, 2);
	nvgFillPaint(vg, bg);
	nvgFill(vg);

	// Knob Shadow
	bg = nvgRadialGradient(vg, frame.origin.x+(int)(pos*frame.size.width),cy+1, kr-3,kr+3, nvgRGBA(0,0,0,64), nvgRGBA(0,0,0,0));
	nvgBeginPath(vg);
	nvgRect(vg, frame.origin.x+(int)(pos*frame.size.width)-kr-5,cy-kr-5,kr*2+5+5,kr*2+5+5+3);
	nvgCircle(vg, frame.origin.x+(int)(pos*frame.size.width),cy, kr);
	nvgPathWinding(vg, NVG_HOLE);
	nvgFillPaint(vg, bg);
	nvgFill(vg);

	// Knob
	knob = nvgLinearGradient(vg, frame.origin.x,cy-kr,frame.origin.x,cy+kr, nvgRGBA(255,255,255,16), nvgRGBA(0,0,0,16));
	nvgBeginPath(vg);
	nvgCircle(vg, frame.origin.x+(int)(pos*frame.size.width),cy, kr-1);
	nvgFillColor(vg, nvgRGBA(40,43,48,255));
	nvgFill(vg);
	nvgFillPaint(vg, knob);
	nvgFill(vg);

	nvgBeginPath(vg);
	nvgCircle(vg, frame.origin.x+(int)(pos*frame.size.width),cy, kr-0.5f);
	nvgStrokeColor(vg, nvgRGBA(0,0,0,92));
	nvgStroke(vg);

	nvgRestore(vg);
}

@end
