#import "CAAnimation.h"

#import "import-private.h"

#include <assert.h>


@implementation CAAnimation

- (id) initWithPropertySetter:(SEL) propertySetter
                    valueType:(enum CAAnimationValueType) type
                   valueRange:(struct CAAnimationValueRange *) range
                  repeatStart:(union CAAnimationValue) repeatStart
                      options:(struct CAAnimationOptions *) options
{
   // no need for super coz NSObject based
   
   // reverses is only used if repeats is set
   assert( ! (options->bits & 0xFFFF));

   self->_relative       = options->timeRange;
   self->_bits           = options->bits & ~0xFFFF;  // mask off our internal state bits
   self->_propertySetter = propertySetter;

   self->_quadratic   = options->curve;

   self->_valueType   = type;
   self->_start       = range->start;
   self->_end         = range->end;
   self->_repeatStart = repeatStart;
   self->_repeatCount = options->repeatCount;
 
   return( self);
}

- (id) initWithPropertySetter:(SEL) propertySetter
                   startColor:(CGColorRef) start
                     endColor:(CGColorRef) end
                      options:(struct CAAnimationOptions *) options
{
   struct CAAnimationValueRange  range;

   range.start.color = start;
   range.end.color   = end;
   return( [self initWithPropertySetter:propertySetter
                              valueType:CAAnimationValueCGColorRef
                             valueRange:&range
                            repeatStart:range.start
                                options:options]);
}                      

- (id) initWithPropertySetter:(SEL) propertySetter
                    startRect:(CGRect) start
                      endRect:(CGRect) end
                      options:(struct CAAnimationOptions *) options
{
   struct CAAnimationValueRange  range;

   range.start.rect = start;
   range.end.rect   = end;
   return( [self initWithPropertySetter:propertySetter
                              valueType:CAAnimationValueCGRect
                             valueRange:&range
                            repeatStart:range.start
                                options:options]);
}                      


- (id) initWithPropertySetter:(SEL) propertySetter
              startFloatValue:(CGFloat) start
                endFloatValue:(CGFloat) end
                      options:(struct CAAnimationOptions *) options
{
   struct CAAnimationValueRange  range;

   range.start.floatValue = start;
   range.end.floatValue   = end;
   return( [self initWithPropertySetter:propertySetter
                              valueType:CAAnimationValueCGFloat
                             valueRange:&range
                            repeatStart:range.start
                                options:options]);
}                      

- (void) reverse
{
   union CAAnimationValue     tmp;     

   self->_relative.delay = 0.0;   

   tmp          = self->_start;
   self->_start = self->_end;
   self->_end   = tmp;
   if( self->_bits & CAAnimationHasReversed)
   { 
      self->_end = tmp;
   }
   else
   {
      self->_end   = self->_repeatStart;
      self->_bits |= CAAnimationHasReversed;
   }
}


- (void) animateLayer:(CALayer *) layer
normalizedRelativeTime:(double) x
{
   union CAAnimationValue   value;

   assert( x >= 0.0 && x <= 1.0);
   
   switch( self->_valueType)
   {
   case CAAnimationValueUndefined :
      abort();

   case CAAnimationValueBOOL :
      value.boolValue = round( (self->_end.boolValue - self->_start.boolValue) * x + self->_start.boolValue);
      mulle_objc_object_call( layer, self->_propertySetter, (void *) (intptr_t) value.boolValue);          
      break;

   case CAAnimationValueNSInteger :
      value.integerValue = round( (self->_end.integerValue - self->_start.integerValue) * x + self->_start.integerValue);
      mulle_objc_object_call( layer, self->_propertySetter, (void *) value.integerValue);          
      break;

   case CAAnimationValueCGFloat :
      value.floatValue = (self->_end.floatValue - self->_start.floatValue) * x + self->_start.floatValue;
      {
         mulle_objc_metaabi_param_block_void_return( float)   param;  

         param.p = value.floatValue;
         mulle_objc_object_call( layer, self->_propertySetter, &param);          
      }
      break;

   case CAAnimationValueCGColorRef :
      value.color.r = (self->_end.color.r - self->_start.color.r) * x + self->_start.color.r;
      value.color.g = (self->_end.color.g - self->_start.color.g) * x + self->_start.color.g;
      value.color.b = (self->_end.color.b - self->_start.color.b) * x + self->_start.color.b;
      value.color.a = (self->_end.color.a - self->_start.color.a) * x + self->_start.color.a;

      {
         mulle_objc_metaabi_param_block_void_return( CGColorRef)   param;  

         param.p = value.color;
         mulle_objc_object_call( layer, self->_propertySetter, &param);          
      }
      break;

   case CAAnimationValueCGPoint :
      value.point.x = (self->_end.point.x - self->_start.point.x) * x + self->_start.point.x;
      value.point.y = (self->_end.point.y - self->_start.point.y) * x + self->_start.point.y;
      {
         mulle_objc_metaabi_param_block_void_return( CGPoint)   param;  

         param.p = value.point;
         mulle_objc_object_call( layer, self->_propertySetter, &param);          
      }
      break;

   case CAAnimationValueCGSize :
      value.size.width  = (self->_end.size.width  - self->_start.size.width)  * x + self->_start.size.width;
      value.size.height = (self->_end.size.height - self->_start.size.height) * x + self->_start.size.height;
      {
         mulle_objc_metaabi_param_block_void_return( CGSize)   param;  

         param.p = value.size;
         mulle_objc_object_call( layer, self->_propertySetter, &param);          
      }
      break;
 
   case CAAnimationValueCGRect :
      value.rect.origin.x    = (self->_end.rect.origin.x - self->_start.rect.origin.x) * x + self->_start.rect.origin.x;
      value.rect.origin.y    = (self->_end.rect.origin.y - self->_start.rect.origin.y) * x + self->_start.rect.origin.y;
      value.rect.size.width  = (self->_end.rect.size.width - self->_start.rect.size.width) * x + self->_start.rect.size.width;
      value.rect.size.height = (self->_end.rect.size.height - self->_start.rect.size.height) * x + self->_start.rect.size.height;
      {
        mulle_objc_metaabi_param_block_void_return( CGRect)   param;  

        param.p = value.rect;
        mulle_objc_object_call( layer, self->_propertySetter, &param);          
      }
      break;
   }
}

- (void) animateLayer:(CALayer *) layer
         absoluteTime:(CAAbsoluteTime) now 
{
   CGFloat                  x;
   CGFloat                  t;
   CAAbsoluteTime           delay;

   if( ! self || self->_relative.duration == 0.0)
      return;

   // turn animation time into absolute
   if( ! (self->_bits & CAAnimationStarted))
   {
      self->_absolute.start = CATimeAdd( now, self->_relative.delay);
      self->_absolute.end   = CATimeAdd( self->_absolute.start, self->_relative.duration);
      self->_bits          |= CAAnimationStarted;
   }

   if( now <= self->_absolute.end)
   {
      if( now < self->_absolute.start) 
         return;
 
      if( _frames++ == 0)
      {
         [_animationDelegate willStart];
      }

      delay = CATimeSubtract( now, self->_absolute.start);
      t     = delay / self->_relative.duration;
      x     = MulleQuadraticGetValueForNormalizedDistance( &self->_quadratic, t);
      if( self->_repeatCount > 0.0)
      {
         if( x > self->_repeatCount)  // exhausted ? Done!
         {
            self->_repeatCount = 0.0;
            return;
         }
      }
      assert( layer);

      [self animateLayer:layer
  normalizedRelativeTime:x];

      if( now < self->_absolute.end)
         return;
   }

   // not repeating ? done
   if( self->_repeatCount == 0.0)
   {
      [_animationDelegate didEnd];
      return;
   }

   // _self->_repeatCount > 0.0 means repeats a finite number
   if( self->_repeatCount > 0.0)
   {
      self->_repeatCount -= 1.0;
      if( self->_repeatCount <= 0.0)
      {
         [_animationDelegate didEnd];
         return;
      }
   }

   // start with next frame, with a new animation
   self->_bits &= ~CAAnimationStarted;
   if( self->_bits & CAAnimationReverses)
      [self reverse];
}

@end



@implementation MulleAnimationDelegate : NSObject

- (void) setIdentifier:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_identifier, s);
}


- (void) dealloc 
{
   MulleObjCObjectDeallocateMemory( self, &_identifier);
   [super dealloc];
}


- (void) willStart
{
   // if this is the first time we got this, then
   // send the delegate a message
   if( _started++)
      return;
   if( ! _animationWillStartSelector)
      return;

   [_delegate performSelector:_animationWillStartSelector
                   withObject:(id) _identifier
                   withObject:_context];      
}

- (void) didEnd
{
   // if we got #animations messages, then the last one
   // to finish sends the delegate emessage
   if( ++_ended != _started)
      return;
   if( ! _animationDidStopSelector)
      return;   
 
   [_delegate performSelector:_animationDidStopSelector
                   withObject:(id) _identifier
                   withObject:_context];
}


- (void) didPreempt
{
   // if we got #animations messages, then the last one
   // to finish sends the delegat message
   if(  _ended == _started)
      return;
   if( ! _animationDidStopSelector)
      return;   
 
   _ended = _started;  // don't send more

   [_delegate performSelector:_animationDidStopSelector
                   withObject:(id) _identifier
                   withObject:_context];
}

@end
