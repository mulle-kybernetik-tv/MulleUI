#import "import.h"

#import "CGColor.h"

//
// UIColor is merely a factory for CGColorRef which is really the
// nanovg color struct
//
// I think colors wrapped into objects is too heavyweight
// In case of need one should use NSValue for that.

@interface UIColor : NSObject

+ (CGColorRef) blackColor;
+ (CGColorRef) whiteColor;
+ (CGColorRef) redColor;
+ (CGColorRef) blueColor;
+ (CGColorRef) greenColor;
+ (CGColorRef) grayColor;
+ (CGColorRef) darkGrayColor;
+ (CGColorRef) lightGrayColor;
+ (CGColorRef) underPageBackgroundColor;
+ (CGColorRef ) colorWithCGColor:(CGColorRef) cgColor;

@end

