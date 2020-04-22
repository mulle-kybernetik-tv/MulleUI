#include "CGGeometry.h"

// TODO: move this stuff to CGBase+MulleObjC.h until CGRect
static inline void   MulleObjectSetBOOL( id obj, SEL sel, BOOL value)
{
   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, (id) value);
}


static inline BOOL   MulleObjectGetBOOL( id obj, SEL sel)
{
   return( (BOOL) mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, obj));
}


static inline void   MulleObjectSetNSInteger( id obj, SEL sel, NSInteger value)
{
   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, (id) value);
}


static inline NSInteger   MulleObjectGetNSInteger( id obj, SEL sel)
{
   return( (NSInteger) mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, obj));
}


static inline void   MulleObjectSetCGFloat( id obj, SEL sel, CGFloat value)
{
   mulle_objc_metaabi_param_block_voidptr_return( struct { CGFloat value; })  param;

   param.p.value = value;

  mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
}


static inline CGFloat   MulleObjectGetCGFloat( id obj, SEL sel)
{
   mulle_objc_metaabi_param_block_voidptr_parameter( struct { CGFloat value; })  param;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
   return( param.r.value);
}


static inline void   MulleObjectSetCGRect( id obj, SEL sel, CGRect rect)
{
   mulle_objc_metaabi_param_block_voidptr_return( struct { CGRect rect; })  param;

   param.p.rect = rect;

  mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
}


static inline CGRect   MulleObjectGetCGRect( id obj, SEL sel)
{
   mulle_objc_metaabi_param_block_voidptr_parameter( struct { CGRect rect; })  param;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
   return( param.r.rect);
}


static inline void   MulleObjectSetCGSize( id obj, SEL sel, CGSize size)
{
   mulle_objc_metaabi_param_block_voidptr_return( struct { CGSize size; })  param;

   param.p.size = size;

  mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
}


static inline CGSize   MulleObjectGetCGSize( id obj, SEL sel)
{
   mulle_objc_metaabi_param_block_voidptr_parameter( struct { CGSize size; })  param;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
   return( param.r.size);
}


static inline void   MulleObjectSetCGPoint( id obj, SEL sel, CGPoint point)
{
   mulle_objc_metaabi_param_block_voidptr_return( struct { CGPoint point; })  param;

   param.p.point = point;

  mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
}


static inline CGPoint   MulleObjectGetCGPoint( id obj, SEL sel)
{
   mulle_objc_metaabi_param_block_voidptr_parameter( struct { CGPoint point; })  param;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
   return( param.r.point);
}


