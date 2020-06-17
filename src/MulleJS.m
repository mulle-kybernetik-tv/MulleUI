//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "MulleJS.h"

#import "MulleJS+Math.h"
#import "MulleJS+MulleUI.h"

#import "import-private.h"

#include <string.h>
#include <stdlib.h>
#include <math.h>


static void jsB_gc(js_State *_state)
{
   int report = js_toboolean(_state, 1);
   js_gc(_state, report);
   js_pushundefined(_state);
}

static void jsB_load(js_State *_state)
{
   int i, n = js_gettop(_state);
   for (i = 1; i < n; ++i) {
      js_loadfile(_state, js_tostring(_state, i));
      js_pushundefined(_state);
      js_call(_state, 0);
      js_pop(_state, 1);
   }
   js_pushundefined(_state);
}

static void jsB_compile(js_State *_state)
{
   const char *source = js_tostring(_state, 1);
   const char *filename = js_isdefined(_state, 2) ? js_tostring(_state, 2) : "[string]";
   js_loadstring(_state, filename, source);
}

static void jsB_print(js_State *_state)
{
   int i, top = js_gettop(_state);
   for (i = 1; i < top; ++i) {
      const char *s = js_tostring(_state, i);
      if (i > 1) putchar(' ');
      fputs(s, stdout);
   }
   putchar('\n');
   js_pushundefined(_state);
}

static void jsB_write(js_State *_state)
{
   int i, top = js_gettop(_state);
   for (i = 1; i < top; ++i) {
      const char *s = js_tostring(_state, i);
      if (i > 1) putchar(' ');
      fputs(s, stdout);
   }
   js_pushundefined(_state);
}


static void jsB_read(js_State *_state)
{
   const char *filename = js_tostring(_state, 1);
   FILE *f;
   char *s;
   int n, t;

   f = fopen(filename, "rb");
   if (!f) {
      js_error(_state, "cannot open file '%s': %s", filename, strerror(errno));
   }

   if (fseek(f, 0, SEEK_END) < 0) {
      fclose(f);
      js_error(_state, "cannot seek in file '%s': %s", filename, strerror(errno));
   }

   n = ftell(f);
   if (n < 0) {
      fclose(f);
      js_error(_state, "cannot tell in file '%s': %s", filename, strerror(errno));
   }

   if (fseek(f, 0, SEEK_SET) < 0) {
      fclose(f);
      js_error(_state, "cannot seek in file '%s': %s", filename, strerror(errno));
   }

   s = malloc(n + 1);
   if (!s) {
      fclose(f);
      js_error(_state, "out of memory");
   }

   t = fread(s, 1, n, f);
   if (t != n) {
      free(s);
      fclose(f);
      js_error(_state, "cannot read data from file '%s': %s", filename, strerror(errno));
   }
   s[n] = 0;

   js_pushstring(_state, s);
   free(s);
   fclose(f);
}

static void jsB_quit(js_State *_state)
{
   exit(js_tonumber(_state, 1));
}

static void jsB_repr(js_State *_state)
{
   js_repr(_state, 1);
}

static const char *require_js =
   "function require(name) {\n"
   "var cache = require.cache;\n"
   "if (name in cache) return cache[name];\n"
   "var exports = {};\n"
   "cache[name] = exports;\n"
   "Function('exports', read(name+'.js'))(exports);\n"
   "return exports;\n"
   "}\n"
   "require.cache = Object.create(null);\n"
;

static const char *stacktrace_js =
   "Error.prototype.toString = function() {\n"
   "if (this.stackTrace) return this.name + ': ' + this.message + this.stackTrace;\n"
   "return this.name + ': ' + this.message;\n"
   "};\n"
;


#pragma mark - example begin 



@implementation MulleJS


- (void) jsPushValue:(id) value
              forKey:(NSString *) key 
             jsState:(js_State *) J
{
   js_pushundefined( J);
}


static void   MulleJS_objectForKey(js_State *J)
{
   char       *s;
   NSString   *key;
   char       *type;
   id         value;
   MulleJS    *self;
   void       *pointer;

   js_getglobal( J, "MulleJS");
   self = js_touserdata(J, -1, MULLEJS_TAG);

   s     = (char *) js_tostring(J, 1);
   key   = @( s);
   value = [self objectForKey:key];
   if( ! value)
   {
      js_pushundefined( J);
      return;
   }

   if( [value isKindOfClass:[NSValue class]])
   {
      type  = [value objCType];
      switch( *type)
      {
      case _C_SEL       : 
      case _C_CHR       : 
      case _C_BOOL      :
      case _C_UCHR      : 
      case _C_SHT       : 
      case _C_USHT      : 
      case _C_INT       : 
      case _C_UINT      : 
      case _C_LNG       : 
      case _C_ULNG      : 
      case _C_LNG_LNG   : 
      case _C_ULNG_LNG  : 
      case _C_FLT       : 
      case _C_DBL       : 
      case _C_LNG_DBL   : 
         js_pushnumber( J, [value doubleValue]);
         return;
      }
   }   

   [self jsPushValue:value
              forKey:key
             jsState:J];
}


#pragma mark - example end


+ (BOOL) isStrict
{
   return( YES);
}

- (instancetype) init 
{
   MulleJS   *js;

   _objectTable = [NSMutableDictionary new];

   _state = js_newstate(NULL, NULL, [[self class] isStrict] ? JS_STRICT : 0);

   // get Object.prototype on stack for js_newuserdata
   js_getglobal(_state, "Object");
   js_getproperty(_state, -1, "prototype");	
   js_newuserdata( _state, MULLEJS_TAG, self, 0);
   js_setglobal(_state, "MulleJS");

  // js_setregistry( _state, "MulleJS");

//   js_newcfunction(_state, jsB_gc, "gc", 0);
//   js_setglobal(_state, "gc");
//
//   js_newcfunction(_state, jsB_load, "load", 1);
//   js_setglobal(_state, "load");
//
//   js_newcfunction(_state, jsB_compile, "compile", 2);
//   js_setglobal(_state, "compile");

   js_newcfunction(_state, jsB_print, "print", 0);
   js_setglobal(_state, "print");

//   js_newcfunction(_state, jsB_write, "write", 0);
//   js_setglobal(_state, "write");
//
//   js_newcfunction(_state, jsB_read, "read", 0);
//   js_setglobal(_state, "read");
//
//   js_newcfunction(_state, jsB_repr, "repr", 0);
//   js_setglobal(_state, "repr");

   js_newcfunction(_state, jsB_quit, "quit", 1);
   js_setglobal(_state, "quit");

   js_newcfunction(_state, MulleJS_objectForKey, "$", 1);
   js_setglobal(_state, "$");

   js_dostring(_state, require_js);
   js_dostring(_state, stacktrace_js);

   [self addMulleUI];
   [self addJavaScriptMathLibrary];

   return( self);
}


- (BOOL) runScriptCString:(char *) s
{
   js_newarray(_state);
//	i = 0;
//	while (xoptind < argc) {
//		js_pushstring(_state, argv[xoptind++]);
//		js_setindex(_state, -2, i++);
//	}
   js_setglobal(_state, "scriptArgs");

   if( js_dostring(_state, s))
      return( NO);
   return( YES);
} 


- (BOOL) runScriptFileCString:(char *) filename
{
   js_newarray(_state);
//	i = 0;
//	while (xoptind < argc) {
//		js_pushstring(_state, argv[xoptind++]);
//		js_setindex(_state, -2, i++);
//	}
   js_setglobal(_state, "scriptArgs");

   if( js_dofile(_state, filename))
      return( NO);
   return( YES);
} 


/*
- (void) addGlobalCFunction:(void (*f)(js_State *))
              argumentCount:(NSUInteger) n
                     forKey:(NSString *) key
{
   char  *s;

   s = [key UTF8String];
   js_newcfunction(_state, f, s, n);
   js_setglobal(_state, s);   
}
*/


- (void) finalize
{
   js_gc(_state, 0);
   js_freestate(_state);
   _state = 0;

   [_objectTable autorelease];
   _objectTable = nil;

   [super finalize];  // call at end
}


- (void *) forward:(void *) param
{
   assert( _objectTable); // window should not forward...
   return( mulle_objc_object_inlinecall_variablemethodid( _objectTable,
                                                          (mulle_objc_methodid_t) _cmd,
                                                          param));
}

@end
