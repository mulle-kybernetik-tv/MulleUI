#import "NSString+CGGeometry.h"

#import "import-private.h"


NSString   *NSStringFromCGPoint( CGPoint point)
{
   return( [NSString stringWithFormat:@"%.2f %.2f", point.x,
                                                    point.y]);
}


NSString   *NSStringFromCGRect( CGRect rect)
{
   return( [NSString stringWithFormat:@ "%.2f %.2f %.2f %.2f", rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height]);  
}
