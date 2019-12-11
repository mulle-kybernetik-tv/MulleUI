# Foundation Incompatibilities

## Missing Classes

NSIndexSet     // need to implement
NSIndexPath    // need to implement
CATransform3D  // actually unused
UINib          // can not support these methods

## Unavailable Classes 

NSString          // turn instance variables into CStrings. Use id<NSString> for interfacing ?
NSDictionary      // turn into NSDictionary * and back with MulleObjectDictionary (TODO)
NSArray           // turn into NSArray * and back with MulleObjectArray

## Questions ?

NSComparisonResult   // we have it
UIEdgeInsets         // TODO


# Language Incompatibilities

ARC
property dot syntax
array indexing of objects

