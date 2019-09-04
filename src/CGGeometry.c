//******************************************************************************
//
// Copyright (c) Microsoft. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#include "CGGeometry.h"
#include <limits.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>


const CGRect    CGRectInfinite = { INFINITY, INFINITY, INFINITY, INFINITY };
const CGPoint   CGPointZero;
const CGRect    CGRectZero;
const CGSize    CGSizeZero;
const CGRect    CGRectNull = { INFINITY, INFINITY, 0.0f, 0.0f };


/**
 @Status Interoperable
*/
void CGRectDivide(CGRect rect, CGRect* slice, CGRect* remainder, CGFloat amount, CGRectEdge edge) {
    if( ! slice || ! remainder)
      return;

    if (CGRectIsNull(rect)) {
        *slice     = CGRectNull;
        *remainder = CGRectNull;
        return;
    }

    amount = 0.0f > amount ? 0.0f : amount;
    rect   = CGRectStandardize(rect);

    /*
    * (0,0)                      (width,0)
    * x-----------------------------x
    * |                             |
    * |                             |
    * |                             |
    * |                             |
    * |                             |
    * x-----------------------------x
    * (0,height)               (width,height)
    *
    *
    * The division is based on CGRectEdge, which edge to divide.
    * e.g CGRectMinYEdge
    *
    *   (0,0)                      (width,0)
    *    x-----------------------------x
    *    | slice            | (amount) |
    *    |                  v          |
    * (0,amount)------------------(width,amount)
    *    | reminder                    |
    *    |                             |
    *    x-----------------------------x
    *   0,height-amount)               (width,height-amount)
    */

    // Set both to rect, then update the sizes.
    *slice = rect;
    *remainder = rect;

    switch (edge) {
        case CGRectMinYEdge:
            amount = (amount > rect.size.height) ? rect.size.height : amount;
            remainder->origin.y += amount;
            if (amount >= rect.size.height) {
                remainder->size.height = 0;
            } else {
                slice->size.height = amount;
                remainder->size.height -= amount;
            }
            break;
        case CGRectMaxYEdge:
            if (amount >= rect.size.height) {
                remainder->size.height = 0;
            } else {
                slice->origin.y += (rect.size.height - amount);
                slice->size.height = amount;
                remainder->size.height -= amount;
            }
            break;
        case CGRectMinXEdge:
            amount = (amount > rect.size.width) ? rect.size.width : amount;
            remainder->origin.x += amount;
            if (amount >= rect.size.width) {
                remainder->size.width = 0;
            } else {
                slice->size.width = amount;
                remainder->size.width -= amount;
            }
            break;
        case CGRectMaxXEdge:
            if (amount >= rect.size.width) {
                remainder->size.width = 0;
            } else {
                remainder->size.width -= amount;
                slice->origin.x += rect.size.width - amount;
                slice->size.width = amount;
            }
            break;
        default:
            abort();
    }
}

/**
 @Status Interoperable
*/
CGRect CGRectIntegral(CGRect r) {
    r = CGRectStandardize(r);

    r.size.width = ceilf(r.origin.x + r.size.width);
    r.size.height = ceilf(r.origin.y + r.size.height);
    r.origin.x = floorf(r.origin.x);
    r.origin.y = floorf(r.origin.y);
    r.size.width -= r.origin.x;
    r.size.height -= r.origin.y;

    return r;
}


/**
 @Status Interoperable
*/
CGRect CGRectIntersection(CGRect r1, CGRect r2) 
{
    r1 = CGRectStandardize(r1);
    r2 = CGRectStandardize(r2);

    CGFloat  x1, y1, x2, y2;
    int isNull = 0;
    CGRect out;

    if (r1.origin.x < r2.origin.x) 
    {
        if( r1.origin.x + r1.size.width < r2.origin.x) 
            return( CGRectNull);

        x1 = MulleCGFloatMinimum(r1.origin.x + r1.size.width, r2.origin.x);
        x2 = MulleCGFloatMinimum(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width);
    } 
    else 
    {
        if (r2.origin.x + r2.size.width < r1.origin.x)
           return (CGRectNull);

        x1 = MulleCGFloatMinimum(r2.origin.x + r2.size.width, r1.origin.x);
        x2 = MulleCGFloatMinimum(r2.origin.x + r2.size.width, r1.origin.x + r1.size.width);
    }

    if (r1.origin.y < r2.origin.y) 
    {
        if (r1.origin.y + r1.size.height < r2.origin.y)
           return (CGRectNull);

        y1 = MulleCGFloatMinimum(r1.origin.y + r1.size.height, r2.origin.y);
        y2 = MulleCGFloatMinimum(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height);
    } 
    else 
    {
        if (r2.origin.y + r2.size.height < r1.origin.y)
           return (CGRectNull);

        y1 = MulleCGFloatMinimum(r2.origin.y + r2.size.height, r1.origin.y);
        y2 = MulleCGFloatMinimum(r2.origin.y + r2.size.height, r1.origin.y + r1.size.height);
    }


   out.origin.x = x1;
   out.origin.y = y1;
   out.size.width = x2 - x1;
   out.size.height = y2 - y1;

   return out;
}

/**
 @Status Interoperable
*/
CGRect CGRectStandardize(CGRect r) {
    CGRect out;

    if (r.size.width < 0.0f) {
        out.origin.x = r.origin.x + r.size.width;
        out.size.width = -r.size.width;
    } else {
        out.origin.x = r.origin.x;
        out.size.width = r.size.width;
    }

    if (r.size.height < 0.0f) {
        out.origin.y = r.origin.y + r.size.height;
        out.size.height = -r.size.height;
    } else {
        out.origin.y = r.origin.y;
        out.size.height = r.size.height;
    }
    return out;
}

/**
 @Status Interoperable
*/
CGRect CGRectUnion(CGRect r1, CGRect r2) {
    if (CGRectIsInfinite(r1)) {
        return r2;
    }
    if (CGRectIsInfinite(r2)) {
        return r1;
    }

    r1 = CGRectStandardize(r1);
    r2 = CGRectStandardize(r2);

    float x1, y1, x2, y2;

    if (r1.origin.x < r2.origin.x) {
        x1 = r1.origin.x;
    } else {
        x1 = r2.origin.x;
    }
    if (r1.origin.y < r2.origin.y) {
        y1 = r1.origin.y;
    } else {
        y1 = r2.origin.y;
    }

    if (r1.origin.x + r1.size.width > r2.origin.x + r2.size.width) {
        x2 = r1.origin.x + r1.size.width;
    } else {
        x2 = r2.origin.x + r2.size.width;
    }
    if (r1.origin.y + r1.size.height > r2.origin.y + r2.size.height) {
        y2 = r1.origin.y + r1.size.height;
    } else {
        y2 = r2.origin.y + r2.size.height;
    }

    CGRect ret;
    ret.origin.x = x1;
    ret.origin.y = y1;
    ret.size.width = x2 - x1;
    ret.size.height = y2 - y1;

    return ret;
}


unsigned int   MulleRectSubdivideByRect( CGRect rect, CGRect other, CGRect output[ 4])
{
   unsigned int   i;
   CGFloat        left_margin;
   CGFloat        right_margin;
   CGFloat        top_margin;
   CGFloat        bottom_margin;
   CGFloat        extent;

   // isn't this overkill ? 
   rect  = CGRectStandardize( rect);
   other = CGRectStandardize( other);

   // and assume other is smack dab in the middle of rect
   //
   //    000000000
   //    111   222
   //    333333333
   //
   // assume other is overlapping middle and part of the bottom
   //
   //    000000000
   //    111   222
   //    111   222
   //
   // assume other is overlapping middle and part of the bottom
   //
   //    000000000
   //    111
   //    111

   i = 0;
   
   if ( ! CGRectIntersectsRect( rect, other))
      return (0);

   top_margin    = CGRectGetMinY( other) - CGRectGetMinY( rect);
   bottom_margin = CGRectGetMaxY( rect)  - CGRectGetMaxY( other);
   left_margin   = CGRectGetMinX( other) - CGRectGetMinX( rect);
   right_margin  = CGRectGetMaxX( rect)  - CGRectGetMaxX( other);

   extent = CGRectGetHeight(rect);
   
   if( top_margin > 0.0)
   {
      output[ i++] = CGRectMake( CGRectGetMinX( rect),
                                 CGRectGetMinY( rect),
                                 CGRectGetWidth( rect),
                                 top_margin);
      extent -= top_margin;
   }
   else
      top_margin = 0.0;

   if( bottom_margin > 0.0)
   {
      output[i++] = CGRectMake(CGRectGetMinX(rect),
                               CGRectGetMaxY(rect) - bottom_margin,
                               CGRectGetWidth(rect),
                               bottom_margin);
      extent -= bottom_margin;
   }


   if( extent > 0.0)
   {
      if( left_margin > 0.0)
      {
         output[i++] = CGRectMake(CGRectGetMinX(rect),
                                  CGRectGetMinY (rect) + top_margin,
                                  left_margin,
                                  extent);
      }

      if( right_margin > 0.0)
      {
         output[i++] = CGRectMake(CGRectGetMaxX(rect) - right_margin,
                                  CGRectGetMinY(rect) + top_margin,
                                  right_margin,
                                  extent);
      }
   }


   return( i);
}
