#import "NSValue+CGGeometry.h"

#import "import-private.h"


@implementation NSValue( CGGeometry)

+ (instancetype) valueWithCGRect:(CGRect) rect
{
   return( [[[self alloc] initWithBytes:&rect
                               objCType:@encode( CGRect)] autorelease]);
}

- (CGRect) CGRectValue
{
   CGRect  rect;

   [self getValue:&rect
             size:sizeof( CGRect)];
   return( rect);
}

+ (instancetype) valueWithCGPoint:(CGPoint) point
{
   return( [[[self alloc] initWithBytes:&point
                               objCType:@encode( CGPoint)] autorelease]);
}

- (CGPoint) CGPointValue
{
   CGPoint   point;

   [self getValue:&point
             size:sizeof( CGPoint)];
   return( point);
}


+ (instancetype) valueWithCGSize:(CGSize) size
{
   return( [[[self alloc] initWithBytes:&size
                               objCType:@encode( CGSize)] autorelease]);
}

- (CGSize) CGSizeValue
{
   CGSize   size;

   [self getValue:&size
             size:sizeof( CGSize)];
   return( size);
}


+ (instancetype) valueWithCGVector:(CGVector) vect
{
   return( [[[self alloc] initWithBytes:&vect
                               objCType:@encode( CGVector)] autorelease]);
}

- (CGVector) CGVectorValue
{
   CGVector   vect;

   [self getValue:&vect
             size:sizeof( CGVector)];
   return( vect);
}

@end
