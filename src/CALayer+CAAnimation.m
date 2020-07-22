#import "CALayer+CAAnimation.h"

#import "import-private.h"

#import "CAAnimation.h"
#import "CGGeometry+MulleObjC.h"
#import "CGColor+MulleObjC.h"
#import "MulleEdgeInsets+MulleObjC.h"
#import "UIView+CAAnimation.h"

struct property_animation_context
{
   CALayer                        *self;
   CALayer                        *snapshot;
   MulleAnimationDelegate         *animationDelegate;
   struct CAAnimationOptions      *animationOptions;
   struct _mulle_objc_infraclass  *infra;
};


// returns 0 on match
static inline int   string_matcher( char *s, char *other, size_t other_len)  
{
   if( strlen( s) != other_len)
      return( 1);
   return( strncmp( s, other, other_len));
}


static void   animate_bool_property( struct _mulle_objc_property *property,
                                     struct property_animation_context  *ctx)
{
   CAAnimation   *animation;
   NSInteger     startValue;
   NSInteger     endValue;
   SEL           getter;
   SEL           setter;

   getter     = mulle_objc_property_get_getter( property);
   startValue = MulleObjectGetBOOL( ctx->snapshot, getter);
   endValue   = MulleObjectGetBOOL( ctx->self, getter);;
   if( startValue == endValue)
      return;

   setter    = mulle_objc_property_get_setter( property);
   animation = [[[CAAnimation alloc] initWithPropertySetter:setter
                                          startIntegerValue:startValue
                                            endIntegerValue:endValue
                                                    options:ctx->animationOptions] autorelease];
   [animation setAnimationDelegate:ctx->animationDelegate];
   [ctx->self addAnimation:animation];

   // reset to start position 
   MulleObjectSetBOOL( ctx->self, setter, startValue);
}


static void   animate_integer_property( struct _mulle_objc_property *property,
                                        struct property_animation_context  *ctx)
{
   CAAnimation   *animation;
   NSInteger     startValue;
   NSInteger     endValue;
   SEL           getter;
   SEL           setter;

   getter     = mulle_objc_property_get_getter( property);
   startValue = MulleObjectGetNSInteger( ctx->snapshot, getter);
   endValue   = MulleObjectGetNSInteger( ctx->self, getter);;
   if( startValue == endValue)
      return;

   setter    = mulle_objc_property_get_setter( property);
   animation = [[[CAAnimation alloc] initWithPropertySetter:setter
                                          startIntegerValue:startValue
                                            endIntegerValue:endValue
                                                    options:ctx->animationOptions] autorelease];
   [animation setAnimationDelegate:ctx->animationDelegate];
   [ctx->self addAnimation:animation];

   // reset to start position 
   MulleObjectSetNSInteger( ctx->self, setter, startValue);
}


static void   animate_float_property( struct _mulle_objc_property *property,
                                       struct property_animation_context  *ctx)
{
   CAAnimation   *animation;
   CGFloat       startValue;
   CGFloat       endValue;
   SEL           getter;
   SEL           setter;

   getter     = mulle_objc_property_get_getter( property);
   startValue = MulleObjectGetCGFloat( ctx->snapshot, getter);
   endValue   = MulleObjectGetCGFloat( ctx->self, getter);;
   if( startValue == endValue)
      return;

   setter    = mulle_objc_property_get_setter( property);
   animation = [[[CAAnimation alloc] initWithPropertySetter:setter
                                            startFloatValue:startValue
                                              endFloatValue:endValue
                                                    options:ctx->animationOptions] autorelease];
   [animation setAnimationDelegate:ctx->animationDelegate];
   [ctx->self addAnimation:animation];

   // reset to start position 
   MulleObjectSetCGFloat( ctx->self, setter, startValue);
}

static void   animate_point_property( struct _mulle_objc_property *property,
                                      struct property_animation_context  *ctx)
{
   CAAnimation  *animation;
   CGPoint       startPoint;
   CGPoint       endPoint;
   SEL           getter;
   SEL           setter;

   getter     = mulle_objc_property_get_getter( property);
   startPoint = MulleObjectGetCGPoint( ctx->snapshot, getter);
   endPoint   = MulleObjectGetCGPoint( ctx->self, getter);    
   if( ! CGPointEqualToPoint( startPoint, endPoint))
   {
      setter    = mulle_objc_property_get_setter( property);
      animation = [[[CAAnimation alloc] initWithPropertySetter:setter 
                                                     startPoint:startPoint
                                                       endPoint:endPoint
                                                       options:ctx->animationOptions] autorelease];
      [animation setAnimationDelegate:ctx->animationDelegate];
      [ctx->self addAnimation:animation];

      // reset to start position 
      // this should work and not trigger another willChange action, as willChange
      // will see the existing snapshot in the layer and do nothing
      // STILL it would be nicer to do this more stealthily by setting the ivar
      // directly
      MulleObjectSetCGPoint( ctx->self, setter, startPoint);
   }  
}


static void   animate_size_property( struct _mulle_objc_property *property,
                                     struct property_animation_context  *ctx)
{
   CAAnimation  *animation;
   CGSize        startSize;
   CGSize        endSize;
   SEL           getter;
   SEL           setter;

   getter    = mulle_objc_property_get_getter( property);
   startSize = MulleObjectGetCGSize( ctx->snapshot, getter);
   endSize   = MulleObjectGetCGSize( ctx->self, getter);    
   if( ! CGSizeEqualToSize( startSize, endSize))
   {
      setter    = mulle_objc_property_get_setter( property);
      animation = [[[CAAnimation alloc] initWithPropertySetter:setter 
                                                     startSize:startSize
                                                       endSize:endSize
                                                       options:ctx->animationOptions] autorelease];
      [animation setAnimationDelegate:ctx->animationDelegate];
      [ctx->self addAnimation:animation];

      // reset to start position 
      // this should work and not trigger another willChange action, as willChange
      // will see the existing snapshot in the layer and do nothing
      // STILL it would be nicer to do this more stealthily by setting the ivar
      // directly
      MulleObjectSetCGSize( ctx->self, setter, startSize);
   }  
}


static void   animate_rect_property( struct _mulle_objc_property *property,
                                      struct property_animation_context  *ctx)
{
   CAAnimation  *animation;
   CGRect        startRect;
   CGRect        endRect;
   SEL           getter;
   SEL           setter;

   getter    = mulle_objc_property_get_getter( property);
   startRect = MulleObjectGetCGRect( ctx->snapshot, getter);
   endRect   = MulleObjectGetCGRect( ctx->self, getter);    
   if( ! CGRectEqualToRect( startRect, endRect))
   {
      setter    = mulle_objc_property_get_setter( property);
      animation = [[[CAAnimation alloc] initWithPropertySetter:setter 
                                                     startRect:startRect
                                                       endRect:endRect
                                                       options:ctx->animationOptions] autorelease];
      [animation setAnimationDelegate:ctx->animationDelegate];
      [ctx->self addAnimation:animation];

      // reset to start position 
      // this should work and not trigger another willChange action, as willChange
      // will see the existing snapshot in the layer and do nothing
      // STILL it would be nicer to do this more stealthily by setting the ivar
      // directly
      MulleObjectSetCGRect( ctx->self, setter, startRect);
   }  
}


static void   animate_insets_property( struct _mulle_objc_property *property,
                                        struct property_animation_context  *ctx)
{
   CAAnimation      *animation;
   MulleEdgeInsets   startInsets;
   MulleEdgeInsets   endInsets;
   SEL               getter;
   SEL               setter;

   getter     = mulle_objc_property_get_getter( property);
   startInsets = MulleObjectGetEdgeInsets( ctx->snapshot, getter);
   endInsets   = MulleObjectGetEdgeInsets( ctx->self, getter);    
   if( ! MulleEdgeInsetsEqualToEdgeInsets( startInsets, endInsets))
   {
      setter    = mulle_objc_property_get_setter( property);
      animation = [[[CAAnimation alloc] initWithPropertySetter:setter 
                                               startEdgeInsets:startInsets
                                                 endEdgeInsets:endInsets
                                                       options:ctx->animationOptions] autorelease];
      [animation setAnimationDelegate:ctx->animationDelegate];
      [ctx->self addAnimation:animation];

      // reset to start position 
      // this should work and not trigger another willChange action, as willChange
      // will see the existing snapshot in the layer and do nothing
      // STILL it would be nicer to do this more stealthily by setting the ivar
      // directly
      MulleObjectSetEdgeInsets( ctx->self, setter, startInsets);
   }  
}


static void   animate_color_property( struct _mulle_objc_property *property,
                                      struct property_animation_context  *ctx)
{
   CAAnimation   *animation;
   CGColorRef    startColor;
   CGColorRef    endColor;  
   SEL           getter;
   SEL           setter;

   getter      = mulle_objc_property_get_getter( property);
   startColor = MulleObjectGetCGColorRef( ctx->snapshot, getter);
   endColor   = MulleObjectGetCGColorRef( ctx->self, getter);    

   if( CGColorEqualToColor( startColor,  endColor))
      return;

   setter    = mulle_objc_property_get_setter( property);
   animation = [[[CAAnimation alloc] initWithPropertySetter:setter 
                                                 startColor:startColor
                                                   endColor:endColor
                                                    options:ctx->animationOptions] autorelease];
   [animation setAnimationDelegate:ctx->animationDelegate];
   [ctx->self addAnimation:animation];

   // reset to start position 
   MulleObjectSetCGColorRef( ctx->self, setter, startColor);
}


@implementation CALayer( CAAnimation)


static mulle_objc_walkcommand_t   
   walkproperties_callback( struct _mulle_objc_property *property,
                            struct _mulle_objc_infraclass *infra,
                            void *userinfo)
{
   struct property_animation_context  *ctx = userinfo;
   char                               *signature;
   char                               *name_b;
   char                               *name_e;
   size_t                             name_len;

   if( ! (_mulle_objc_property_get_bits( property) & _mulle_objc_property_observable))
      return( mulle_objc_walk_ok);

   signature = mulle_objc_property_get_signature( property);


//   printf( "%s @property %s = %s\n", _mulle_objc_infraclass_get_name( infra),
//                                      mulle_objc_property_get_name( property),
//                                      signature);

   switch( *signature)
   {
   default           : return( mulle_objc_walk_ok); // warn ????

   case _C_BOOL      : animate_bool_property( property, ctx); 
                       return( mulle_objc_walk_ok);
   case _C_LNG       : if( sizeof( long) == sizeof( NSInteger)) 
                          animate_integer_property( property, ctx); 
                       return( mulle_objc_walk_ok);
   case _C_LNG_LNG   : if( sizeof( long long) == sizeof( NSInteger)) 
                          animate_integer_property( property, ctx); 
                       return( mulle_objc_walk_ok);

   case _C_FLT       : if( sizeof( float) == sizeof( CGFloat))
                          animate_float_property( property, ctx); 
                       return( mulle_objc_walk_ok);
   case _C_DBL       : if( sizeof( double) == sizeof( CGFloat))
                          animate_float_property( property, ctx); 
                       return( mulle_objc_walk_ok);
   case _C_STRUCT_B  : // default code
      break;
   }

   // struct code
   name_b = signature + 1;
   name_e = strchr( name_b, '=');
   assert( name_e && strchr( name_b, ',') > name_e);
   name_len = name_e - name_b;

   // CGRect, NVGColor, CGSize, CGPoint, MulleEdgeInsets
   if( name_len < 6)
      return( mulle_objc_walk_ok);

   switch( name_b[ 2])
   {
   case 'G' : if( ! string_matcher( "NVGcolor", name_b, name_len))
                  animate_color_property( property, ctx);
              return( mulle_objc_walk_ok);
   case 'P' : if( ! string_matcher( "CGPoint", name_b, name_len))
                  animate_point_property( property, ctx);
              return( mulle_objc_walk_ok);
   case 'S' : if( ! string_matcher( "CGSize", name_b, name_len))
                  animate_size_property( property, ctx);
              return( mulle_objc_walk_ok);
   case 'l' : if( ! string_matcher( "MulleEdgeInsets", name_b, name_len))
                  animate_insets_property( property, ctx);
              return( mulle_objc_walk_ok);
   case 'R' : if( ! string_matcher( "CGRect", name_b, name_len))
                  animate_rect_property( property, ctx);
             return( mulle_objc_walk_ok);
   }   

   return( mulle_objc_walk_ok);
}


- (void) animatePropertiesWithSnapshotlayer:(CALayer *) snapshot
                          animationDelegate:(MulleAnimationDelegate *) animationDelegate
                           animationOptions:(struct CAAnimationOptions *) animationOptions
{
   struct property_animation_context   ctxt;
   struct _mulle_objc_infraclass       *infra;

   infra                  = mulle_objc_object_get_infraclass( snapshot);
   assert( infra);
   ctxt.snapshot          = snapshot;
   ctxt.animationDelegate = animationDelegate;
   ctxt.animationOptions  = animationOptions;
   ctxt.infra             = infra;
   ctxt.self              = self;

	_mulle_objc_infraclass_walk_properties( infra,
                                           -1,  // inherit nothing
                                           walkproperties_callback,
                                           &ctxt);
}



- (void) addAnimation:(CAAnimation *) animation
{
   assert( animation);

   assert( _mulle_pointerarray_find( &_animations, animation) == -1);
   _mulle_pointerarray_add( &_animations, animation);
}


- (void) removeAllAnimations
{
   struct mulle_pointerarrayenumerator   rover;
   CAAnimation                           *animation;

   rover = mulle_pointerarray_enumerate_nil( &_animations);
   while( (animation = _mulle_pointerarrayenumerator_next( &rover)))
      [animation autorelease];
   mulle_pointerarrayenumerator_done( &rover); 

   _mulle_pointerarray_done( &_animations);
   _mulle_pointerarray_init( &_animations, 16, 0, NULL);
}


- (NSUInteger) numberOfAnimations
{
   return( mulle_pointerarray_get_count( &_animations));
}


- (void) willAnimateWithAbsoluteTime:(CAAbsoluteTime) time;
{
}


- (void) animateWithAbsoluteTime:(CAAbsoluteTime) renderTime
{
   struct mulle_pointerarrayenumerator   rover;
   CAAnimation                           *animation;

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   rover = mulle_pointerarray_enumerate_nil( &_animations);
   while( (animation = _mulle_pointerarrayenumerator_next( &rover)))
      [animation animateLayer:self
                 absoluteTime:renderTime];
   mulle_pointerarrayenumerator_done( &rover);   
}


MulleQuadratic   CALayerQuadraticForCurveType( NSUInteger curvetype)
{
   MulleQuadratic   quadratic;

   switch( [UIView animationCurve])
   {
   case UIViewAnimationCurveEaseInOut: 
      MulleQuadraticInit( &quadratic, 0.0, 0.025, 1.0 - 0.025, 1.0);
      break;
      
   case UIViewAnimationCurveEaseOut: 
      MulleQuadraticInit( &quadratic, 0.0, 0.9, 0.9, 1.0);
      break;

   case UIViewAnimationCurveEaseIn: 
      MulleQuadraticInit( &quadratic, 0.0, 0.0, 0.1, 1.0);
      break;

   default :
      MulleQuadraticInit( &quadratic, 0.0, 0.333, 0.666, 1.0);
      break;
   }   

   return( quadratic);
}


- (void) commitImplicitAnimationsWithAnimationID:(char *) animationsID
                               animationDelegate:(MulleAnimationDelegate *) animationDelegate
{
   CAAnimation                  *animation;
   CGColorRef                   endColor;
   CGColorRef                   startColor;
   CGRect                       endRect;
   CGRect                       startRect;
   float                        repeatCount;
   struct CAAnimationOptions    options;
   struct CARelativeTimeRange   timeRange;

   if( ! _snapshot)
      return;

   [self removeAllAnimations];

   options.timeRange   = CARelativeTimeRangeMake( [UIView animationDelay], [UIView animationDuration]);
   options.repeatCount = [UIView animationRepeatCount];
   options.bits        = [UIView animationRepeatAutoreverses] ? CAAnimationReverses : 0;
   options.curve       = CALayerQuadraticForCurveType( [UIView animationCurve]);

   /** Our animatable properties
       subclasses might want to add more
    **/
   [self animatePropertiesWithSnapshotlayer:_snapshot
                          animationDelegate:animationDelegate
                           animationOptions:&options];

   [_snapshot autorelease];
   _snapshot = nil;  
}

@end
