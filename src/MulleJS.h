//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "import.h"


@interface MulleJS : NSObject
{
	void                 *_state;
   NSMutableDictionary  *_objectTable;
}

+ (BOOL) isStrict;

- (BOOL) runScriptCString:(char *) s;
- (BOOL) runScriptFileCString:(char *) filename;

- (void) setObject:(id) object
            forKey:(id <NSCopying>) key;

@end
