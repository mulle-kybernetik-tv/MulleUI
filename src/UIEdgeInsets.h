#include "MulleEdgeInsets.h"



typedef struct MulleEdgeInsets  UIEdgeInsets;


static inline UIEdgeInsets   UIEdgeInsetsMake( CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
{
	return( MulleEdgeInsetsMake( top, left, bottom, right));
}


static inline BOOL   UIEdgeInsetsEqualToEdgeInsets( UIEdgeInsets insets1, UIEdgeInsets insets2)
{
	return( MulleEdgeInsetsEqualToEdgeInsets( insets1, insets2));
}


static inline CGRect   UIEdgeInsetsInsetRect( CGRect rect, UIEdgeInsets insets)
{
	return( MulleEdgeInsetsInsetRect( rect, insets));
}

#define UIEdgeInsetsZero   MulleEdgeInsetsZero

