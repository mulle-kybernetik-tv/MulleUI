#import "CAAnimation.h"

#import "import-private.h"


void   CAAnimationInit( struct CAAnimation *info,
                        SEL propertySetter,
                        enum CAAnimationValueType type,
                        struct CAAnimationValueRange *range,
                        struct CARelativeTimeRange timeRange,
                        NSUInteger bits)
{
   memset( info, 0, sizeof( *info));
  
   info->relative       = timeRange;
   info->bits           = bits & ~0xFFFF;  // mask off our internal state bits
   info->propertySetter = propertySetter;

   MulleQuadraticInit( &info->quadratic, 0.0, 0.025, 1.0 - 0.025, 1.0);

   info->valueType   = type;
   info->start       = range->start;
   info->end         = range->end;
   info->repeatStart = info->start;
}


void   CAPointAnimationInit( struct CAAnimation *info,
                            SEL propertySetter,
                            CGPoint start,
                            CGPoint end,
                            struct CARelativeTimeRange timeRange,
                            NSUInteger bits)
{
   struct CAAnimationValueRange   range;

   range.start.point = start;
   range.end.point   = end;

   CAAnimationInit( info, propertySetter, CAAnimationValueCGPoint, &range, timeRange, bits);
}


void   CARectAnimationInit( struct CAAnimation *info,
                            SEL propertySetter,
                            CGRect  start,
                            CGRect  end,
                            struct CARelativeTimeRange timeRange,
                            NSUInteger bits)
{
   struct CAAnimationValueRange   range;

   range.start.rect = start;
   range.end.rect   = end;

   CAAnimationInit( info, propertySetter, CAAnimationValueCGRect, &range, timeRange, bits);
}


void   CAColorAnimationInit( struct CAAnimation *info,
                             SEL propertySetter,
                             CGColorRef  start,
                             CGColorRef  end,
                             struct CARelativeTimeRange timeRange,
                             NSUInteger bits)
{
   struct CAAnimationValueRange   range;

   range.start.color = start;
   range.end.color   = end;

   CAAnimationInit( info, propertySetter, CAAnimationValueCGColorRef, &range, timeRange, bits);
}



static inline void    CAAnimationInfoReverseAnimation( struct CAAnimation *info)
{
   union CAAnimationValue     tmp;     

   info->relative.delay = 0.0;   

   tmp         = info->start;
   info->start = info->end;
   info->end   = tmp;
   if( info->bits & CAAnimationHasReversed)
   { 
      info->end = tmp;
   }
   else
   {
      info->end   = info->repeatStart;
      info->bits |= CAAnimationHasReversed;
   }
}


void  CAAnimationAnimate( struct CAAnimation *info, CALayer *layer, CAAbsoluteTime now) 
{
   union CAAnimationValue   value;
   CGFloat                x;
   CGFloat                t;
   CAAbsoluteTime         delay;

   if( ! info || info->relative.duration == 0.0)
      return;

   // turn animation time into absolute
   if( ! (info->bits & CAAnimationStarted))
   {
      info->absolute.start = CATimeAdd( now, info->relative.delay);
      info->absolute.end   = CATimeAdd( info->absolute.start, info->relative.duration);
      info->bits          |= CAAnimationStarted;
   }

   if( now <= info->absolute.end)
   {
      if( now < info->absolute.start) 
         return;
 
      delay = CATimeSubtract( now, info->absolute.start);
      t     = delay / info->relative.duration;
      x     = MulleQuadraticGetValueForNormalizedDistance( &info->quadratic, t);

      assert( layer);

      switch( info->valueType)
      {
      case CAAnimationValueUndefined :
         abort();

      case CAAnimationValueBOOL :
         value.boolValue = round( (info->end.boolValue - info->start.boolValue) * x + info->start.boolValue);
         mulle_objc_object_call( layer, info->propertySetter, (void *) (intptr_t) value.boolValue);          
         break;

      case CAAnimationValueNSInteger :
         value.integerValue = round( (info->end.integerValue - info->start.integerValue) * x + info->start.integerValue);
         mulle_objc_object_call( layer, info->propertySetter, (void *) value.integerValue);          
         break;

      case CAAnimationValueCGFloat :
         value.floatValue = (info->end.floatValue - info->start.floatValue) * x + info->start.floatValue;
         {
            mulle_objc_metaabi_param_block_void_return( float)   param;  

            param.p = value.floatValue;
            mulle_objc_object_call( layer, info->propertySetter, &param);          
         }
         break;

      case CAAnimationValueCGColorRef :
         value.color.r = (info->end.color.r - info->start.color.r) * x + info->start.color.r;
         value.color.g = (info->end.color.g - info->start.color.g) * x + info->start.color.g;
         value.color.b = (info->end.color.b - info->start.color.b) * x + info->start.color.b;
         value.color.a = (info->end.color.a - info->start.color.a) * x + info->start.color.a;

         {
            mulle_objc_metaabi_param_block_void_return( CGColorRef)   param;  

            param.p = value.color;
            mulle_objc_object_call( layer, info->propertySetter, &param);          
         }
         break;

      case CAAnimationValueCGPoint :
         value.point.x = (info->end.point.x - info->start.point.x) * x + info->start.point.x;
         value.point.y = (info->end.point.y - info->start.point.y) * x + info->start.point.y;
         {
           mulle_objc_metaabi_param_block_void_return( CGPoint)   param;  

           param.p = value.point;
           mulle_objc_object_call( layer, info->propertySetter, &param);          
         }
         break;

      case CAAnimationValueCGSize :
         value.size.width  = (info->end.size.width  - info->start.size.width)  * x + info->start.size.width;
         value.size.height = (info->end.size.height - info->start.size.height) * x + info->start.size.height;
         {
           mulle_objc_metaabi_param_block_void_return( CGSize)   param;  

           param.p = value.size;
           mulle_objc_object_call( layer, info->propertySetter, &param);          
         }
         break;
    
      case CAAnimationValueCGRect :
         value.rect.origin.x    = (info->end.rect.origin.x - info->start.rect.origin.x) * x + info->start.rect.origin.x;
         value.rect.origin.y    = (info->end.rect.origin.y - info->start.rect.origin.y) * x + info->start.rect.origin.y;
         value.rect.size.width  = (info->end.rect.size.width - info->start.rect.size.width) * x + info->start.rect.size.width;
         value.rect.size.height = (info->end.rect.size.height - info->start.rect.size.height) * x + info->start.rect.size.height;
         {
           mulle_objc_metaabi_param_block_void_return( CGRect)   param;  

           param.p = value.rect;
           mulle_objc_object_call( layer, info->propertySetter, &param);          
         }
         break;
      }

      if( now < info->absolute.end)
         return;
   }

   if( ! (info->bits & CAAnimationRepeats))
      return;

   // start with next frame, with a new animation
   info->bits &= ~CAAnimationStarted;
   if( info->bits & CAAnimationReverses)
   {
      CAAnimationInfoReverseAnimation( info);
   }
}
