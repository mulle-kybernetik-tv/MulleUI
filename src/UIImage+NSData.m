//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIImage+NSData.h"

#import "import-private.h"



@implementation UIImage ( NSData)

- (instancetype) initWithFileData:(NSData *) data
{
   return( [self initWithFileMulleData:[data mulleData]
                          sharingObject:data]);
}

+ (instancetype) imageWithFileData:(NSData *) data
{
   return( [[[self alloc] initWithFileMulleData:[data mulleData]
                                  sharingObject:data] autorelease]);
}

@end
