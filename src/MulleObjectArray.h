//
// lightweight NSArray class, that wraps a mulle-pointer-array
//
#import "import.h"


//
// this array references a mulle-pointerarray
// it doesn't own it. its purpose is for use in enumerations and loops
//
@interface MulleObjectArray : NSObject < NSArray, NSFastEnumeration>
{
   struct mulle_pointerarray  *_pointerarray;
   BOOL                       _freeWhenDone;
}

- (instancetype) initWithPointerarray:(struct mulle_pointerarray *) p
                         freeWhenDone:(BOOL) yn;

- (id <NSEnumeration>) objectEnumerator;

@end


// most basic array, can't do random access inserts!
@interface MulleMutableObjectArray : MulleObjectArray < NSMutableArray>
@end