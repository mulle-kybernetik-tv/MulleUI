#import "MulleSliderLayer.h"

#import "CGContext.h"
#import "CGFont.h"
#import "CGColor.h"
#import "MulleEdgeInsets.h"


@implementation MulleSliderLayer : CALayer

- (instancetype) initWithFrame:(CGRect) frame
{
   self = [super initWithFrame:frame];
   if( self)
      self->_maximumValue = 1.0;
   [self setControlColor:MulleColorCreate( 0x000000FF)];
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


// border around knob, drawn once per radius so to speak
#define KNOB_OUTLINE  4.0
#define SLOT_WIDTH    4.0

- (CGFloat) knobRadiusWithFrame:(CGRect) frame 
{
   if( frame.size.width >= frame.size.height)
      return( (int)(frame.size.height * 0.5f - KNOB_OUTLINE / 2));
   else
      return( (int)(frame.size.width * 0.5f - KNOB_OUTLINE / 2));
}


- (CGRect) controlRectWithFrame:(CGRect) frame 
{
   CGRect    rect;
   CGFloat   kr;

   kr   = [self knobRadiusWithFrame:frame];

   rect = MulleEdgeInsetsInsetRect( _controlInsets, frame);

   if( frame.size.width >= frame.size.height)
   {
      rect.origin.x    += kr + KNOB_OUTLINE / 2;
      rect.size.width  -= kr * 2 + KNOB_OUTLINE;
   }
   else
   {
      rect.origin.y     += kr + KNOB_OUTLINE / 2;
      rect.size.height  -= kr * 2 + KNOB_OUTLINE;
   }

   return( rect);
}


- (BOOL) drawContentsInContext:(CGContext *) context
{
   CGRect              frame;
   CGRect              rect;
   NVGpaint            bg;
	NVGpaint            knob;
   struct NVGcontext   *vg;
   float               normalized;
	float               centerX;   // relative vertical position (0.25 is first quarter, 0.5 is center)
	float               centerY;   // relative vertical position (0.25 is first quarter, 0.5 is center)
	float               kr;   // knob radius 
   float               pos;  // knob position from 0.0 to 1.0 
   BOOL                isHorizontal;

   pos        = 0.0;
   normalized = [self maximumValue] - [self minimumValue];
   if( normalized > 0.0)
      pos = [self value] / normalized;

   // stupido protection
   assert( pos >= 0.0 && pos <= 1.0);

   vg    = [context nvgContext];
   frame = [self frame];

   // knob radius 
   kr    = [self knobRadiusWithFrame:frame];
   // slider position from 0.0 to 1.0 

   // Slot rect
   rect    = [self controlRectWithFrame:frame];
 	centerX = CGRectGetMidX( frame);
 	centerY = CGRectGetMidY( frame);

	nvgBeginPath(vg);

   isHorizontal = frame.size.width >= frame.size.height;
   if(isHorizontal)
   	nvgRoundedRect(vg, rect.origin.x , centerY - SLOT_WIDTH / 2, rect.size.width, SLOT_WIDTH, 3);
   else
   	nvgRoundedRect(vg, centerX - SLOT_WIDTH / 2, rect.origin.y, SLOT_WIDTH, rect.size.height,  3);
   
	nvgFillColor(vg, [self controlColor]);
	nvgFill(vg);


//	// Knob Shadow
//	bg = nvgRadialGradient(vg, frame.origin.x+(int)(pos*frame.size.width),centerY+1, kr-3,kr+3, nvgRGBA(0,0,0,64), nvgRGBA(0,0,0,0));
//	nvgBeginPath(vg);
//	nvgRect(vg, frame.origin.x+(int)(pos*frame.size.width)-kr-5,centerY-kr-5,kr*2+5+5,kr*2+5+5+3);
//	nvgCircle(vg, frame.origin.x+(int)(pos*frame.size.width),centerY, kr);
//	nvgPathWinding(vg, NVG_HOLE);
//	nvgFillPaint(vg, bg);
//	nvgFill(vg);

	// Knob
	nvgBeginPath(vg);
   if( isHorizontal)
   	nvgCircle(vg, rect.origin.x+(int)(pos*rect.size.width),centerY, kr-KNOB_OUTLINE/2);
   else
   	nvgCircle(vg, centerX, rect.origin.y+(int)(pos*rect.size.height), kr-KNOB_OUTLINE/2);
	nvgFillColor(vg, [self controlColor]);
	nvgFill(vg);
//	nvgFillPaint(vg, knob);
//	nvgFill(vg);

	nvgBeginPath(vg);
   if( isHorizontal)
   	nvgCircle(vg, rect.origin.x+(int)(pos*rect.size.width),centerY, kr-KNOB_OUTLINE/2);
   else
   	nvgCircle(vg, centerX, rect.origin.y+(int)(pos*rect.size.height), kr-KNOB_OUTLINE/2);
	nvgStrokeColor(vg, [self backgroundColor]);
   nvgStrokeWidth( vg, KNOB_OUTLINE);
	nvgStroke(vg);

   return( NO);
}

@end
