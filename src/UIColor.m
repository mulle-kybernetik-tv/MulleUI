#import "UIColor.h"


@implementation UIColor


+ (instancetype) alloc 
{
   assert( 0 && "don't create UIColor instances");
   return( nil);
}


- (instancetype) init 
{
   assert( 0 && "don't create UIColor instances");
   [self release];
   return( nil);
}



+ (CGColorRef) blackColor     { return( getNVGColor( 0x000000FF)); }

+ (CGColorRef) whiteColor     { return( getNVGColor( 0xFFFFFFFF)); }
+ (CGColorRef) redColor       { return( getNVGColor( 0xFF0000FF)); }
+ (CGColorRef) greenColor     { return( getNVGColor( 0x00FF00FF)); }
+ (CGColorRef) blueColor      { return( getNVGColor( 0x0000FFFF)); }
+ (CGColorRef) grayColor      { return( getNVGColor( 0x7F7F7FFF)); } 
+ (CGColorRef) darkGrayColor  { return( getNVGColor( 0x3F3F3FFF)); } 
+ (CGColorRef) lightGrayColor { return( getNVGColor( 0xBFBFBFFF)); } 
+ (CGColorRef) yellowColor    { return( getNVGColor( 0xFFFF00FF)); }

// maus grau :) -> Loriot Eheberatung
+ (CGColorRef) underPageBackgroundColor  { return( getNVGColor( 0x6b716fFF)); } 
+ (CGColorRef ) colorWithCGColor:(CGColorRef) cgColor  { return( cgColor); }

@end