/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Copyright (c) Microsoft. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __cg_geometry_h__
#define __cg_geometry_h__

#include "CGBase.h"
#include <stdint.h>
#include <math.h>
#include <assert.h>


// TODO: move elsewhere
typedef struct mulle_int_size
{
   int   width;
   int   height;
} mulle_int_size;


// TODO: move elsewhere
typedef struct mulle_bitmap_size
{
   struct mulle_int_size   size;
   unsigned char           colorComponents;
} mulle_bitmap_size;


typedef struct {
    CGFloat dx;
    CGFloat dy;
} CGVector;

typedef enum 
{ 
   CGRectMinXEdge, 
   CGRectMinYEdge, 
   CGRectMaxXEdge, 
   CGRectMaxYEdge 
} CGRectEdge;

const CGRect CGRectInfinite;
const CGPoint CGPointZero;
const CGRect CGRectZero;
const CGSize CGSizeZero;
const CGRect CGRectNull;

/**
@Status Interoperable
*/
static inline CGRect CGRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    CGRect result = { { x, y }, { width, height } };
    return result;
}

/**
@Status Interoperable
*/
static inline CGPoint CGPointMake(CGFloat x, CGFloat y) {
    CGPoint result = { x, y };
    return result;
}

/**
@Status Interoperable
*/
static inline CGSize CGSizeMake(CGFloat x, CGFloat y) {
    CGSize result = { x, y };
    return result;
}

/**
@Status Interoperable
*/
static inline CGVector CGVectorMake(CGFloat dx, CGFloat dy) {
    CGVector result = { dx, dy };
    return result;
}

/**
@Status Interoperable
*/
static inline int CGSizeEqualToSize(CGSize a, CGSize b) {
    return a.width == b.width && a.height == b.height;
}

/**
@Status Interoperable
*/
static inline CGFloat CGRectGetMinX(CGRect rect) {
    return rect.origin.x;
}

/**
@Status Interoperable
GetMaxY is a misnomer, its really the first Y point not inside the rectangle.
*/
static inline CGFloat CGRectGetMaxX(CGRect rect) {
    return rect.origin.x + rect.size.width;
}

/**
@Status Interoperable
*/
static inline CGFloat CGRectGetMidX(CGRect rect) {
    return( rect.origin.x + rect.size.width / 2);
}

/**
@Status Interoperable
*/
static inline CGFloat CGRectGetMinY(CGRect rect) {
    return rect.origin.y;
}

/**
@Status Interoperable
GetMaxY is a misnomer, its really the first Y point not inside the rectangle.
*/
static inline CGFloat CGRectGetMaxY(CGRect rect) {
    return(rect.origin.y + rect.size.height);
}

/**
@Status Interoperable
*/
static inline CGFloat CGRectGetMidY(CGRect rect) {
    return( rect.origin.y + rect.size.height / 2);
}

/**
@Status Interoperable
*/
static inline CGFloat CGRectGetWidth(CGRect rect) {
    return rect.size.width;
}

/**
@Status Interoperable
*/
static inline CGFloat CGRectGetHeight(CGRect rect) {
    return rect.size.height;
}

/**
@Status Interoperable
*/
static inline int CGRectContainsPoint(CGRect rect, CGPoint point) {
    return (point.x >= CGRectGetMinX(rect) && point.x < CGRectGetMaxX(rect)) &&
           (point.y >= CGRectGetMinY(rect) && point.y < CGRectGetMaxY(rect));
}

/**
@Status Interoperable
*/
static inline int CGPointEqualToPoint(CGPoint a, CGPoint b) {
    return( (a.x == b.x) && (a.y == b.y));
}

/**
@Status Interoperable
*/
static inline CGRect CGRectInset(CGRect rect, CGFloat dx, CGFloat dy) {
    rect.origin.x    += dx;
    rect.origin.y    += dy;
    rect.size.width  -= dx * 2;
    rect.size.height -= dy * 2;
    return rect;
}

/**
@Status Interoperable
*/
static inline CGRect CGRectOffset(CGRect rect, CGFloat dx, CGFloat dy) {
    rect.origin.x += dx;
    rect.origin.y += dy;
    return rect;
}

/**
@Status Interoperable
*/
static inline int CGRectIsEmpty(CGRect rect) {
    return ((rect.size.width == 0) && (rect.size.height == 0));
}

/**
@Status Interoperable
   CGRectMake( 2.0, 0.0, 2.0, 1.0) and CGRectMake( 0.0, 0.0, 2.0, 1.0)
   are not considered intersecting, though mathematically they are.
   This is so that "adjacent" rectangles are not considered intersecting.
   CGRectIntersection will return an intersection of 0 width or height though!
*/
static inline int CGRectIntersectsRect(CGRect a, CGRect b) {
    return !((b.origin.x >= CGRectGetMaxX( a)) || (b.origin.y >= CGRectGetMaxY( a)) ||
             (a.origin.x >= CGRectGetMaxX( b)) || (a.origin.y >= CGRectGetMaxY( b)));
}

/**
@Status Interoperable
*/
static inline int CGRectEqualToRect(CGRect a, CGRect b) {
    return CGPointEqualToPoint(a.origin, b.origin) && CGSizeEqualToSize(a.size, b.size);
}

/**
@Status Interoperable
*/
static inline int CGRectIsNull(CGRect rect) {
    return CGRectEqualToRect(rect, CGRectNull);
}

/**
@Status Interoperable
*/
static inline int CGRectIsInfinite(CGRect rect) {
    return (isinf(rect.origin.x) || isinf(rect.origin.y) || isinf(rect.size.width) || isinf(rect.size.height));
}

/**
@Status Interoperable
*/
static inline int CGRectContainsRect(CGRect a, CGRect b) {
    return( CGRectGetMinX(b) >= CGRectGetMinX(a) && 
            CGRectGetMaxX(b) <= CGRectGetMaxX(a) && 
            CGRectGetMinY(b) >= CGRectGetMinY(a) &&
            CGRectGetMaxY(b) <= CGRectGetMaxY(a));
}

CGRect CGRectIntegral(CGRect rect);
CGRect CGRectIntersection(CGRect r1, CGRect r2);
CGRect CGRectStandardize(CGRect rect);
CGRect CGRectUnion(CGRect a, CGRect b);

void CGRectDivide(CGRect rect, CGRect* slice, CGRect* remainder, CGFloat amount, CGRectEdge edge);

unsigned int   MulleRectSubdivideByRect( CGRect rect, CGRect other, CGRect output[ 4]);


typedef struct MulleQuadratic
{
   CGFloat   value[ 4];
} MulleQuadratic;  


static inline void   MulleQuadraticInit( MulleQuadratic *q,
                                         CGFloat p0,
                                         CGFloat p1,
                                         CGFloat p2,
                                         CGFloat p3)
{
   assert( p0 >= 0.0 && p0 <= 1.0);
   assert( p1 >= 0.0 && p1 <= 1.0);
   assert( p2 >= 0.0 && p2 <= 1.0);
   assert( p3 >= 0.0 && p3 <= 1.0);

   q->value[ 0] = p0;
   q->value[ 1] = p1;
   q->value[ 2] = p2;
   q->value[ 3] = p3;
}


static inline CGFloat   MulleQuadraticGetValueForNormalizedDistance( MulleQuadratic *b,
                                                                     CGFloat t)
{
   CGFloat   value;

   assert( t >= 0.0 && t <= 1.0);

   value = (1 - t) * (1 - t) * (1 - t) * b->value[0] +
       3 * (1 - t) * (1 - t) * t * b->value[1] +
       3 * (1 - t) * t * t * b->value[2] +
       t * t * t * b->value[3];
   return( value);
}


typedef struct MulleQuadraticBezier
{
   MulleQuadratic   x;
   MulleQuadratic   y;
} MulleQuadraticBezier;  // not CGPoint for supposed improved CPU caching


static inline void   MulleQuadraticBezierInit( MulleQuadraticBezier *b,
                                               CGPoint p0,
                                               CGPoint p1,
                                               CGPoint p2,
                                               CGPoint p3)
{
   MulleQuadraticInit( &b->x, p0.x, p1.x, p2.x, p3.x);
   MulleQuadraticInit( &b->y, p0.y, p1.y, p2.y, p3.y);
}

CGPoint   MulleQuadraticBezierGetPointForNormalizedDistance( MulleQuadraticBezier *b, 
                                                             CGFloat t);


#endif
