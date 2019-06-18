#import "MulleCheckboxLayer.h"

#import "CGContext.h"
#import "CGFont.h"

//
// presumably unicode for checkmark
//
#define ICON_CHECK 0x2713


// TODO: use mulle_utf32 conversion instead ?
static char  *cpToUTF8(int cp, char* str)
{
	int n = 0;
	if (cp < 0x80) n = 1;
	else if (cp < 0x800) n = 2;
	else if (cp < 0x10000) n = 3;
	else if (cp < 0x200000) n = 4;
	else if (cp < 0x4000000) n = 5;
	else if (cp <= 0x7fffffff) n = 6;
	str[n] = '\0';
	switch (n) {
	case 6: str[5] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x4000000;
	case 5: str[4] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x200000;
	case 4: str[3] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x10000;
	case 3: str[2] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x800;
	case 2: str[1] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0xc0;
	case 1: str[0] = cp;
	}
	return str;
}


@implementation MulleCheckboxLayer : CALayer


- (void) drawContentsInContext:(CGContext *) context
{
   CGFloat             fontSize;
   CGFont              *font;
   CGRect              frame;
   char                *name;
   char                icon[8];
   NVGpaint            bg;
   struct NVGcontext   *vg;

   font = [context fontWithName:_fontName ? _fontName : "sans"];
   name = [font name];  // get actual name, which could have different address

   fontSize = [self fontSize];
   if( fontSize == 0.0)
      fontSize = 10.0;

   vg     = [context nvgContext];
	nvgFontSize( vg, fontSize);
	nvgFontFace( vg, name);
   nvgFillColor(vg, nvgRGBA(255, 255, 255, 160));

   frame = [self frame];
   nvgTextAlign(vg, NVG_ALIGN_LEFT | NVG_ALIGN_MIDDLE);
   nvgText(vg, frame.origin.x + 28, frame.origin.y + frame.size.height * 0.5f, _cString, NULL);

   bg = nvgBoxGradient(vg, frame.origin.x + 1, frame.origin.y + (int)(frame.size.height * 0.5f) - 9 + 1, 18, 18, 3, 3, nvgRGBA(0, 0, 0, 32), nvgRGBA(0, 0, 0, 92));
   nvgBeginPath(vg);
   nvgRoundedRect(vg, frame.origin.x + 1, frame.origin.y + (int)(frame.size.height * 0.5f) - 9, 18, 18, 3);
   nvgFillPaint(vg, bg);
   nvgFill(vg);

   if( [self isChecked])
   {
      font = [context fontWithName:"icons"];
      name = [font name];  // get actual name, which could have different address

      nvgFontSize(vg, 40);
      nvgFontFace(vg, name);
      nvgFillColor(vg, nvgRGBA(255, 255, 255, 128));
      nvgTextAlign(vg, NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE);
      nvgText(vg, frame.origin.x + 9 + 2, frame.origin.y + frame.size.height * 0.5f, cpToUTF8(ICON_CHECK, icon), NULL);
   }
}

@end
