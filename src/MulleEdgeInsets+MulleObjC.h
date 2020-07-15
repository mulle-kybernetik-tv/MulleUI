//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef mulle_edge_insets_mulleobjc_h__
#define mulle_edge_insets_mulleobjc_h__

#include "MulleEdgeInsets.h"


static inline void   MulleObjectSetEdgeInsets( id obj, SEL sel, MulleEdgeInsets insets)
{
   mulle_metaabi_struct_voidptr_return( struct { MulleEdgeInsets insets; })  param;

   param.p.insets = insets;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
}


static inline MulleEdgeInsets   MulleObjectGetEdgeInsets( id obj, SEL sel)
{
   mulle_metaabi_struct_voidptr_parameter( struct { MulleEdgeInsets insets; })  param;

   mulle_objc_object_call( obj, (mulle_objc_methodid_t) sel, &param);
   return( param.r.insets);
}

#endif
