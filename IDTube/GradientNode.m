
#import "GradientNode.h"

@implementation GradientNode

+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing
{
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myContext);
    CGContextClipToRect(myContext, bounds);
    
    NSInteger componentCount = 2;
    
    CGFloat zero = 0.0;
    CGFloat one = 1.0;
    CGFloat locations[2] = {zero, one};
    CGFloat components[8] = {zero, zero, zero, one, zero, zero, zero, zero};
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorSpace, components, locations, componentCount);
    
    CGPoint myStartPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds));
    CGPoint myEndPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    CGContextDrawLinearGradient(myContext, myGradient, myStartPoint, myEndPoint, kCGGradientDrawsAfterEndLocation);
    
    CGContextRestoreGState(myContext);
}

@end
