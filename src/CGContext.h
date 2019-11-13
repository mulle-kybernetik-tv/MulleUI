//******************************************************************************
//
// Copyright (c) Microsoft. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************
#import "import.h"

#include "CGGeometry.h"

#include "nanoperf.h"


typedef enum 
{
//  CG Drawing Bitfield   |STROKE|   |FILL  |   |EO    |
    kCGPathStroke =       (1 << 0),
    kCGPathFill =                    (1 << 1),
    kCGPathFillStroke =   (1 << 0) | (1 << 1),
    kCGPathEOFill =                  (1 << 1) | (1 << 2),
    kCGPathEOFillStroke = (1 << 0) | (1 << 1) | (1 << 2),
} CGPathDrawingMode;
// clang-format on


typedef enum
{
    kCGInterpolationDefault = 0,
    kCGInterpolationNone = 1,
    kCGInterpolationLow = 2,
    kCGInterpolationMedium = 4,
    kCGInterpolationHigh = 3
} CGInterpolationQuality;

typedef enum
{
    // Each of these constants has a Facility and a Facility Value, documented below.
    // 0xAABB
    //   ^  ^
    //   +--|---- Composition Facility (Primitive Composition, Direct2D Blend Effect, Special Operator)
    //      +---- Composition facility value (usually mapped directly from Direct2D):
    //            Blends: https://msdn.microsoft.com/en-us/library/windows/desktop/dn934217(v=vs.85).aspx
    //            Composition: https://msdn.microsoft.com/en-us/library/windows/desktop/hh446995(v=vs.85).aspx

    // D2D Blend Effect Modes
    kCGBlendModeMultiply = 0x0100,
    kCGBlendModeScreen = 0x0101,
    kCGBlendModeDarken = 0x0102,
    kCGBlendModeLighten = 0x0103,

    kCGBlendModeColorBurn = 0x0105,
    kCGBlendModeColorDodge = 0x0109,

    kCGBlendModeOverlay = 0x010B,
    kCGBlendModeSoftLight = 0x010C,
    kCGBlendModeHardLight = 0x010D,

    kCGBlendModeDifference = 0x0112,
    kCGBlendModeExclusion = 0x0113,

    kCGBlendModeHue = 0x0114,
    kCGBlendModeSaturation = 0x0115,
    kCGBlendModeColor = 0x0116,
    kCGBlendModeLuminosity = 0x0117,

    // D2D Composite Draw Modes
    kCGBlendModeSourceOver = 0x0200,
    kCGBlendModeDestinationOver = 0x0201,

    kCGBlendModeSourceIn = 0x0402,
    kCGBlendModeDestinationIn = 0x0403,

    kCGBlendModeSourceOut = 0x0404,
    kCGBlendModeDestinationOut = 0x0205,

    kCGBlendModeSourceAtop = 0x0206,
    kCGBlendModeDestinationAtop = 0x0407,

    kCGBlendModeXOR = 0x0208,
    kCGBlendModePlusLighter = 0x0209,

    kCGBlendModeCopy = 0x040A,

    kCGBlendModePlusDarker = kCGBlendModePlusLighter, // [Unsupported right now, maps to kCGBlendModePlusLighter with a warning.]

    // Special mode (clears the affected region)
    kCGBlendModeClear = 0x0800,

    kCGBlendModeNormal = kCGBlendModeSourceOver,
} CGBlendMode;

// clang-format off
typedef enum {
//  CG Drawing Bitfield     |FILL  |   |STROKE|   |CLIP  |
    kCGTextInvisible = 0,
    kCGTextFill =           (1 << 0),
    kCGTextStroke =                    (1 << 1),
    kCGTextFillStroke =     (1 << 0) | (1 << 1),
    kCGTextClip =                                 (1 << 2),
    kCGTextFillClip =       (1 << 0) |            (1 << 2),
    kCGTextStrokeClip =                (1 << 1) | (1 << 2),
    kCGTextFillStrokeClip = (1 << 0) | (1 << 1) | (1 << 2)
} CGTextDrawingMode;
// clang-format on


struct NVGcontext;

@class CGFont;
@class UIImage;


struct MulleNVGPerformance
{
   // perf measurements
   double             dt;
	double             prevt;
   double             cpuTime;
   struct PerfGraph   fps;
   struct PerfGraph   cpuGraph;
   struct PerfGraph   gpuGraph;
   struct PerfGraph   memGraph;
   struct GPUtimer    gpuTimer;
   BOOL               enabled;
};


struct MulleFrameInfo 
{
   CGRect        frame;
   CGSize        windowSize;
   CGSize        framebufferSize;
   CGVector      UIScale;
   CGFloat       pixelRatio;
   NSUInteger    renderFrame;      // current frame nr (can wrap)
   NSUInteger    refreshRate;      // often 60 Hz
   BOOL          isPerfEnabled;
};

//
// could make those variable public ?
// for OpenGL we have one context per OpenGL, to keep fonts and 
// other textures around. Each frame is encloded in a 
// startRender and an endRender. frames can't be nested.
//
@interface CGContext : NSObject
{
	struct NVGcontext            *_vg;	
   struct MulleNVGPerformance   _perf;
   struct MulleFrameInfo        _currentFrameInfo;
   struct mulle_pointerarray    *_framebufferImages;
   BOOL                         _isRendering;
}

- (struct NVGcontext *) nvgContext;

- (void) startRenderWithFrameInfo:(struct MulleFrameInfo *) info;
- (void) endRender;
- (void) resetTransform;

- (CGFont *) fontWithName:(char *) s;
- (CGFloat) fontScale;
- (int) textureIDForImage:(UIImage *) image;
- (void) clearFramebuffer;
- (void) getCurrentFrameInfo:(struct MulleFrameInfo *) info; 
- (struct MulleFrameInfo *) currentFrameInfo;

- (UIImage *) textureImageWithSize:(CGSize) size 
                           options:(NSUInteger) options;
- (void) removeTextureImage:(UIImage *) image; 

@end

typedef CGContext   *CGContextRef;


#if 0
void CGContextFlush(CGContextRef c);
void CGContextRelease(CGContextRef c);
CGContextRef CGContextRetain(CGContextRef c);

void CGContextSaveGState(CGContextRef c);
void CGContextRestoreGState(CGContextRef c);
CGInterpolationQuality CGContextGetInterpolationQuality(CGContextRef c);
void CGContextSetInterpolationQuality(CGContextRef c, CGInterpolationQuality quality);

void CGContextSetLineCap(CGContextRef c, CGLineCap cap);
void CGContextSetLineDash(CGContextRef c, CGFloat phase, const CGFloat* lengths, size_t count);
void CGContextSetLineJoin(CGContextRef c, CGLineJoin join);
void CGContextSetLineWidth(CGContextRef c, CGFloat width);
void CGContextSetMiterLimit(CGContextRef c, CGFloat limit);

void CGContextSetPatternPhase(CGContextRef c, CGSize phase);
void CGContextSetFillPattern(CGContextRef c, CGPatternRef pattern, const CGFloat* components);

void CGContextSetShouldAntialias(CGContextRef c, bool shouldAntialias);
void CGContextSetStrokePattern(CGContextRef c, CGPatternRef pattern, const CGFloat* components);

void CGContextSetBlendMode(CGContextRef c, CGBlendMode mode);
void CGContextSetAllowsAntialiasing(CGContextRef c, bool allowsAntialiasing);
void CGContextSetAllowsFontSmoothing(CGContextRef c, bool allowsFontSmoothing);
void CGContextSetShouldSmoothFonts(CGContextRef c, bool shouldSmoothFonts);
void CGContextSetAllowsFontSubpixelPositioning(CGContextRef c, bool allowsFontSubpixelPositioning);
void CGContextSetShouldSubpixelPositionFonts(CGContextRef c, bool shouldSubpixelPositionFonts);
void CGContextSetAllowsFontSubpixelQuantization(CGContextRef c, bool allowsFontSubpixelQuantization);
void CGContextSetShouldSubpixelQuantizeFonts(CGContextRef c, bool shouldSubpixelQuantizeFonts);

void CGContextAddArc(
    CGContextRef c, CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle, int clockwise);
void CGContextAddArcToPoint(CGContextRef c, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, CGFloat radius);
void CGContextAddCurveToPoint(
    CGContextRef c, CGFloat cp1x, CGFloat cp1y, CGFloat cp2x, CGFloat cp2y, CGFloat x, CGFloat y);
void CGContextAddLines(CGContextRef c, const CGPoint* points, size_t count);
void CGContextAddLineToPoint(CGContextRef c, CGFloat x, CGFloat y);
void CGContextAddPath(CGContextRef c, CGPathRef path);

CGPathRef CGContextCopyPath(CGContextRef c);

void CGContextAddQuadCurveToPoint(CGContextRef c, CGFloat cpx, CGFloat cpy, CGFloat x, CGFloat y);
void CGContextAddRect(CGContextRef c, CGRect rect);
void CGContextAddRects(CGContextRef c, const CGRect* rects, size_t count);
void CGContextBeginPath(CGContextRef c);
void CGContextClosePath(CGContextRef c);
void CGContextMoveToPoint(CGContextRef c, CGFloat x, CGFloat y);
void CGContextAddEllipseInRect(CGContextRef c, CGRect rect);
void CGContextClearRect(CGContextRef c, CGRect rect);
void CGContextDrawPath(CGContextRef c, CGPathDrawingMode mode);
void CGContextEOFillPath(CGContextRef c);
void CGContextFillPath(CGContextRef c);
void CGContextFillRect(CGContextRef c, CGRect rect);

void CGContextFillRects(CGContextRef c, const CGRect* rects, size_t count);

void CGContextFillEllipseInRect(CGContextRef c, CGRect rect);
void CGContextStrokePath(CGContextRef c);
void CGContextStrokeRect(CGContextRef c, CGRect rect);
void CGContextStrokeRectWithWidth(CGContextRef c, CGRect rect, CGFloat width);
void CGContextReplacePathWithStrokedPath(CGContextRef c);
void CGContextStrokeEllipseInRect(CGContextRef c, CGRect rect);
void CGContextStrokeLineSegments(CGContextRef c, const CGPoint* points, size_t count);
bool CGContextIsPathEmpty(CGContextRef c);

CGPoint CGContextGetPathCurrentPoint(CGContextRef c);

CGRect CGContextGetPathBoundingBox(CGContextRef c);

bool CGContextPathContainsPoint(CGContextRef c, CGPoint point, CGPathDrawingMode mode);

void CGContextClip(CGContextRef c);
void CGContextEOClip(CGContextRef c);
void CGContextClipToRect(CGContextRef c, CGRect rect);
void CGContextClipToRects(CGContextRef c, const CGRect* rects, size_t count);
CGRect CGContextGetClipBoundingBox(CGContextRef c);
void CGContextClipToMask(CGContextRef c, CGRect rect, CGImageRef mask);
void CGContextSetAlpha(CGContextRef c, CGFloat alpha);

void CGContextSetCMYKFillColor(
    CGContextRef c, CGFloat cyan, CGFloat magenta, CGFloat yellow, CGFloat black, CGFloat alpha);

void CGContextSetFillColor(CGContextRef c, const CGFloat* components);
void CGContextSetCMYKStrokeColor(
    CGContextRef c, CGFloat cyan, CGFloat magenta, CGFloat yellow, CGFloat black, CGFloat alpha);
void CGContextSetFillColorSpace(CGContextRef c, CGColorSpaceRef space);

void CGContextSetFillColorWithColor(CGContextRef c, CGColorRef color);
void CGContextSetGrayFillColor(CGContextRef c, CGFloat gray, CGFloat alpha);
void CGContextSetGrayStrokeColor(CGContextRef c, CGFloat gray, CGFloat alpha);
void CGContextSetRGBFillColor(CGContextRef c, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
void CGContextSetRGBStrokeColor(CGContextRef c, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);

void CGContextSetShadow(CGContextRef c, CGSize offset, CGFloat blur);
void CGContextSetShadowWithColor(CGContextRef c, CGSize offset, CGFloat blur, CGColorRef color);

void CGContextSetStrokeColor(CGContextRef c, const CGFloat* components);

void CGContextSetStrokeColorSpace(CGContextRef c, CGColorSpaceRef space);

void CGContextSetStrokeColorWithColor(CGContextRef c, CGColorRef color);
void CGContextConcatCTM(CGContextRef c, CGAffineTransform transform);
CGAffineTransform CGContextGetCTM(CGContextRef c);
void CGContextRotateCTM(CGContextRef c, CGFloat angle);
void CGContextScaleCTM(CGContextRef c, CGFloat sx, CGFloat sy);
void CGContextTranslateCTM(CGContextRef c, CGFloat tx, CGFloat ty);

void CGContextBeginTransparencyLayer(CGContextRef c, CFDictionaryRef auxiliaryInfo);
void CGContextBeginTransparencyLayerWithRect(CGContextRef c, CGRect rect, CFDictionaryRef auxInfo);
void CGContextEndTransparencyLayer(CGContextRef c);

void CGContextDrawTiledImage(CGContextRef c, CGRect rect, CGImageRef image);
void CGContextDrawImage(CGContextRef c, CGRect rect, CGImageRef image);

void CGContextDrawPDFPage(CGContextRef c, CGPDFPageRef page) STUB_METHOD;

void CGContextDrawLinearGradient(
    CGContextRef c, CGGradientRef gradient, CGPoint startPoint, CGPoint endPoint, CGGradientDrawingOptions options);
void CGContextDrawRadialGradient(CGContextRef c,
                                                     CGGradientRef gradient,
                                                     CGPoint startCenter,
                                                     CGFloat startRadius,
                                                     CGPoint endCenter,
                                                     CGFloat endRadius,
                                                     CGGradientDrawingOptions options);

void CGContextDrawShading(CGContextRef c, CGShadingRef shading) STUB_METHOD;
void CGContextBeginPage(CGContextRef c, const CGRect* mediaBox) STUB_METHOD;
void CGContextEndPage(CGContextRef c) STUB_METHOD;

void CGContextShowGlyphs(CGContextRef c, const CGGlyph* g, size_t count);
void CGContextShowGlyphsAtPoint(CGContextRef c, CGFloat x, CGFloat y, const CGGlyph* glyphs, size_t count);
void CGContextShowGlyphsWithAdvances(CGContextRef c, const CGGlyph* glyphs, const CGSize* advances, size_t count);

void CGContextShowGlyphsAtPositions(CGContextRef c, const CGGlyph* glyphs, const CGPoint* positions, size_t count)
    STUB_METHOD;

CGAffineTransform CGContextGetTextMatrix(CGContextRef c);
CGPoint CGContextGetTextPosition(CGContextRef c);
void CGContextSelectFont(CGContextRef c, const char* name, CGFloat size, CGTextEncoding textEncoding);

void CGContextSetCharacterSpacing(CGContextRef c, CGFloat spacing) STUB_METHOD;

void CGContextSetFont(CGContextRef c, CGFontRef font);
void CGContextSetFontSize(CGContextRef c, CGFloat size);
void CGContextSetTextDrawingMode(CGContextRef c, CGTextDrawingMode mode);
void CGContextSetTextMatrix(CGContextRef c, CGAffineTransform t);
void CGContextSetTextPosition(CGContextRef c, CGFloat x, CGFloat y);
void CGContextShowText(CGContextRef c, const char* string, size_t length);

void CGContextShowTextAtPoint(CGContextRef c, CGFloat x, CGFloat y, const char* string, size_t length);

CGAffineTransform CGContextGetUserSpaceToDeviceSpaceTransform(CGContextRef c);
CGPoint CGContextConvertPointToDeviceSpace(CGContextRef c, CGPoint point);
CGPoint CGContextConvertPointToUserSpace(CGContextRef c, CGPoint point);
CGSize CGContextConvertSizeToDeviceSpace(CGContextRef c, CGSize size);
CGSize CGContextConvertSizeToUserSpace(CGContextRef c, CGSize size);
CGRect CGContextConvertRectToDeviceSpace(CGContextRef c, CGRect rect);
CGRect CGContextConvertRectToUserSpace(CGContextRef c, CGRect rect);

#endif

