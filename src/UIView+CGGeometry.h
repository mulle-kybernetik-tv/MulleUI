#include "UIView.h"
#include "CGGeometry.h"

//******************************************************************************
//
// Copyright (c) Microsoft Corporation. All rights reserved.
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


@interface UIView( CGGeometry)

- (CGPoint) translatedPoint:(CGPoint) point;


- (CGRect) convertRect:(CGRect) pos toView:(UIView*)toView;
- (CGRect) convertRect:(CGRect) pos fromView:(UIView*)fromView;
- (CGPoint) convertPoint:(CGPoint) pos toView:(UIView*)toView;
- (CGPoint) convertPoint:(CGPoint) pos fromView:(UIView*)fromView;

- (void) dumpWithIndent:(NSUInteger) indent;
- (void) dump;

@end
