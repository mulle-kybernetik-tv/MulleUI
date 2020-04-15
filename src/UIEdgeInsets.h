#include <MulleObjC/MulleObjCIntegralType.h>  // for BOOL
#include "CGGeometry.h"
#include <string.h>


// typedef this off something like CGEdgeInsets, so we can use this
// in layers...

typedef struct 
{
	CGFloat   top;
	CGFloat   bottom;
	CGFloat   left;
	CGFloat   right;
} UIEdgeInsets;


static inline UIEdgeInsets   UIEdgeInsetsMake( CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
{
	return( (UIEdgeInsets){ .top = top, .left = left, .bottom = bottom, .right = right });	
}


static inline BOOL   UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsets insets1, UIEdgeInsets insets2)
{
	return( ! memcmp( &insets1, &insets2, sizeof( UIEdgeInsets)));
}


static inline CGRect   UIEdgeInsetsInsetRect( CGRect rect, UIEdgeInsets insets)
{
	rect.origin.x    += insets.left;
	rect.origin.y    += insets.top;
	rect.size.width  -= insets.right + insets.left;
	rect.size.height -= insets.top + insets.bottom;
	return( rect);
}

extern const UIEdgeInsets   UIEdgeInsetsZero;

