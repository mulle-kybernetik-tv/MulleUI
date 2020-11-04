//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIImage+NSData.h"

#import "import-private.h"



@implementation UIImage ( NSData)

- (instancetype) initWithData:(NSData *) data
{
   return( [self initWithMulleData:[data mulleData]
                     sharingObject:data]);
}

+ (instancetype) imageWithData:(NSData *) data
{
   return( [[[self alloc] initWithMulleData:[data mulleData]
                              sharingObject:data] autorelease]);
}

@end
