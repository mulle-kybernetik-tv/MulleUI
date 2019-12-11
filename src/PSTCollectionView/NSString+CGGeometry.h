#include "CGGeometry.h"

#import "import.h"

@class NSString;


NSString   *NSStringFromCGPoint( CGPoint point);
NSString   *NSStringFromCGRect( CGRect rect);

static inline NSString   *NSStringFromCGVector( CGVector vektor)
{
   return( NSStringFromCGPoint(  * (CGPoint *) &vektor));
}

static inline NSString   *NSStringFromCGSize( CGSize size)
{
   return( NSStringFromCGPoint(  * (CGPoint *) &size));
}
