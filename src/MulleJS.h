//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "import.h"


#define mulle_js_define( x, n)  { #x, x, n }
struct function_table
{ 
   char *name; 
   void (*f)( js_State *); 
   int  n_args;
};


#define MULLEJS_TAG        "MulleJS"      // used for objectForKey:



@interface MulleJS : NSObject
{
	void                 *_state;
   NSMutableDictionary  *_objectTable;
}

+ (BOOL) isStrict;

- (BOOL) runScriptCString:(char *) s;
- (BOOL) runScriptFileCString:(char *) filename;

/*
- (void) addGlobalCFunction:(void (*f)(js_State *))
                     forKey:(NSString *) key;
*/    

- (void) jsPushValue:(id) value
              forKey:(NSString *) key 
             jsState:(js_State *) J;                 
@end


@interface MulleJS( Forward)


- (void) setObject:(id) object
            forKey:(id <NSCopying>) key;
- (id) objectForKey:(id <NSCopying>) key;

@end

