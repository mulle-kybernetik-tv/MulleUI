//
//  PSTGridLayoutInfo.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTGridLayoutInfo.h"
#import "PSTGridLayoutSection.h"
#import "PSTGridLayoutItem.h"
#import "NSIndexPath+PSTCollectionViewAdditions.h"
#import "NSIndexPath.h"
#import "NSString+CGGeometry.h"


@implementation PSTGridLayoutInfo

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _sections = [NSMutableArray new];
    }
    return self;
}

- (NSString * )description {
    return [NSString stringWithFormat:@"<%@: %p dimension:%.1f horizontal:%d contentSize:%@ sections:%@>", NSStringFromClass([self class]), self, [self dimension], [self horizontal], NSStringFromCGSize([self contentSize]), [self sections]];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (PSTGridLayoutInfo *)snapshot {
    PSTGridLayoutInfo *layoutInfo = [[[self class] new] autorelease];
    [layoutInfo setSections:[self sections]];
    [layoutInfo setRowAlignmentOptions:[self rowAlignmentOptions]];
    [layoutInfo setUsesFloatingHeaderFooter:[self usesFloatingHeaderFooter]];
    [layoutInfo setDimension:[self dimension]];
    [layoutInfo setHorizontal:[self horizontal]];
    [layoutInfo setLeftToRight:[self leftToRight]];
    [layoutInfo setContentSize:[self contentSize]];
    return layoutInfo;
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSTGridLayoutSection *section = [[self sections] objectAtIndex:(NSUInteger)[indexPath section]];
    CGRect itemFrame;
    if ([section fixedItemSize]) {
        itemFrame = (CGRect){.size=[section itemSize]};
    }else {
        itemFrame = [[[section items] objectAtIndex:(NSUInteger)[indexPath item]] itemFrame];
    }
    return itemFrame;
}

- (id)addSection {
    PSTGridLayoutSection *section = [[PSTGridLayoutSection new] autorelease];
    [section setRowAlignmentOptions:[self rowAlignmentOptions]];
    [section setLayoutInfo:self];
    [_sections addObject:section];
    [self invalidate:NO];
    return section;
}

- (void)invalidate:(BOOL)arg {
    _isValid = NO;
}

- (void) setSections:(NSArray *) array
{
   [_sections autorelease];
   _sections = [array mutableCopy];
} 
- (NSArray *) sections
{
   return( _sections);
}
@end
