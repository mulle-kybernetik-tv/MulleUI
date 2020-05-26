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
#ifndef __cg_base_h__
#define __cg_base_h__

#include <float.h>

typedef float CGFloat;
#define CGFLOAT_MIN FLT_MIN
#define CGFLOAT_MAX FLT_MAX
#define CGFLOAT_IS_DOUBLE 0


enum
{
   MulleHorizontalIndex = 0,
   MulleVerticalIndex   = 1
};

typedef struct CGPoint {
	union 
   {
		CGFloat     value[2];
		struct 
      {
			CGFloat  x;
			CGFloat  y;
		};
	};
} CGPoint;


typedef struct CGSize {
	union 
   {
		CGFloat     value[2];
		struct 
      {
			CGFloat  width;
			CGFloat  height;
		};
	};
} CGSize;


typedef struct CGVector {
	union 
   {
		CGFloat     value[2];
		struct 
      {
			CGFloat  dx;
			CGFloat  dy;
		};
	};
} CGVector;



typedef struct CGRect {
    CGPoint  origin;
    CGSize   size;
} CGRect;


static inline CGFloat   MulleCGFloatMaximum(float x, CGFloat y)
{
   return( x > y ? x : y);
}

static inline CGFloat   MulleCGFloatMinimum(CGFloat x, CGFloat y)
{
   return( x < y ? x : y);
}

#endif
