#include "CGGeometry.h"

#import "import.h"

@interface NSValue( CGGeometry)

+ (instancetype) valueWithCGPoint:(CGPoint) point;
- (CGPoint) CGPointValue;
+ (instancetype) valueWithCGRect:(CGRect) rect;
- (CGRect) CGRectValue;
+ (instancetype) valueWithCGSize:(CGSize) size;
- (CGSize) CGSizeValue;
+ (instancetype) valueWithCGVector:(CGVector) vect;
- (CGVector) CGVectorValue;


@end

