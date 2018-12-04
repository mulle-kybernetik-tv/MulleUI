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
#import "CGGeometry.h"

typedef struct {
    CGFloat a;
    CGFloat b;
    CGFloat c;
    CGFloat d;
    CGFloat tx;
    CGFloat ty;
} CGAffineTransform;

const CGAffineTransform CGAffineTransformIdentity;

CGAffineTransform CGAffineTransformMake(CGFloat a, CGFloat b, CGFloat c, CGFloat d, CGFloat tx, CGFloat ty);

CGPoint CGPointApplyAffineTransform(CGPoint point, CGAffineTransform xform);

CGSize CGSizeApplyAffineTransform(CGSize size, CGAffineTransform xform);

CGRect CGRectApplyAffineTransform(CGRect rect, CGAffineTransform t);

CGAffineTransform CGAffineTransformMakeRotation(CGFloat radians);
CGAffineTransform CGAffineTransformMakeScale(CGFloat scalex, CGFloat scaley);
CGAffineTransform CGAffineTransformMakeTranslation(CGFloat tx, CGFloat ty);

CGAffineTransform CGAffineTransformConcat(CGAffineTransform xform, CGAffineTransform append);
CGAffineTransform CGAffineTransformInvert(CGAffineTransform xform);

CGAffineTransform CGAffineTransformRotate(CGAffineTransform xform, CGFloat radians);
CGAffineTransform CGAffineTransformScale(CGAffineTransform xform, CGFloat scalex, CGFloat scaley);
CGAffineTransform CGAffineTransformTranslate(CGAffineTransform xform, CGFloat tx, CGFloat ty);

int CGAffineTransformIsIdentity(CGAffineTransform t);

int CGAffineTransformEqualToTransform(CGAffineTransform t1, CGAffineTransform t2);
