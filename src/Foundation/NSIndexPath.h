//******************************************************************************
//
// Copyright (c) Microsoft. All rights reserved.
// Copyright (c) 2007 Dirk Theisen
// Portions Copyright (c) 2013 Peter Steinberger. All rights reserved.
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
#import "import.h"


@interface NSIndexPath : NSObject <NSCopying, MulleObjCImmutable>
{
   NSUInteger    *_indexes;
   NSUInteger    _length;
}


+ (instancetype) indexPathWithIndex:(NSUInteger) index;
+ (instancetype) indexPathWithIndexes:(NSUInteger *) indexes
                               length:(NSUInteger) length;
- (instancetype) initWithIndex:(NSUInteger) index;
- (instancetype) initWithIndexes:(NSUInteger *) indexes
                          length:(NSUInteger) length;
- (instancetype) init;

- (NSUInteger) length;

- (NSUInteger) indexAtPosition:(NSUInteger)node;
- (NSIndexPath *) indexPathByAddingIndex:(NSUInteger)index;
- (NSIndexPath *) indexPathByRemovingLastIndex;
- (void) getIndexes:(NSUInteger *) indexes
              range:(NSRange)positionRange;
- (void) getIndexes:(NSUInteger *) indexes;
- (NSComparisonResult) compare:(NSIndexPath * )indexPath;

@end
