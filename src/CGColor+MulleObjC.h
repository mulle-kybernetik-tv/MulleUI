#import "CGColor.h"

#import "import-private.h"


static inline void   MulleObjectSetCGColorRef( id obj, SEL sel, CGColorRef color)
{
   mulle_objc_metaabi_param_block_voidptr_return( struct { CGColorRef color; })  param;

   param.p.color = color;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
}


static inline CGColorRef   MulleObjectGetCGColorRef( id obj, SEL sel)
{
   mulle_objc_metaabi_param_block_voidptr_parameter( struct { CGColorRef color; })  param;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
   return( param.r.color);
}