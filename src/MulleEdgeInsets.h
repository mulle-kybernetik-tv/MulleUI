//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef mulle_edge_insets_h__
#define mulle_edge_insets_h__

#include <MulleObjC/MulleObjCIntegralType.h>  // for BOOL
#include "CGGeometry.h"
#include <string.h>


// typedef this off something like CGEdgeInsets, so we can use this
// in layers...

typedef struct MulleEdgeInsets
{
	CGFloat   top;
	CGFloat   bottom;
	CGFloat   left;
	CGFloat   right;
} MulleEdgeInsets;


static inline MulleEdgeInsets   MulleEdgeInsetsMake( CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
{
	return( (MulleEdgeInsets){ .top = top, .left = left, .bottom = bottom, .right = right });	
}


static inline BOOL   MulleEdgeInsetsEqualToEdgeInsets( MulleEdgeInsets insets1, MulleEdgeInsets insets2)
{
	return( ! memcmp( &insets1, &insets2, sizeof( MulleEdgeInsets)));
}


static inline CGRect   MulleEdgeInsetsInsetRect( MulleEdgeInsets insets, CGRect rect)
{
	rect.origin.x    += insets.left;
	rect.origin.y    += insets.top;
	rect.size.width  -= insets.right + insets.left;
	rect.size.height -= insets.top + insets.bottom;
	return( rect);
}


static inline CGRect   MulleEdgeInsetsExtrudeRect( MulleEdgeInsets insets, CGRect rect)
{
	rect.origin.x    -= insets.left;
	rect.origin.y    -= insets.top;
	rect.size.width  += insets.right + insets.left;
	rect.size.height += insets.top + insets.bottom;
	return( rect);
}


extern const MulleEdgeInsets   MulleEdgeInsetsZero;

#endif
