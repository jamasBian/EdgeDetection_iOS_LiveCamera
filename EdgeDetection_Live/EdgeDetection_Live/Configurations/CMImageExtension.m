//
//  CMImageExtension.m
//  ColorMagic
//
//  Created by Mostafizur Rahman on 11/9/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import "CMImageExtension.h"

@implementation CMImageExtension
+(UIImage *) imageFromCVImageBufferRef:(CVImageBufferRef)imageBuffer{
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    const CGSize iamge_size = CGSizeMake(width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width,
                                                    height,
                                                    8,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGContextTranslateCTM(newContext, iamge_size.width/2, iamge_size.height/2);
    CGContextRotateCTM(newContext, M_PI_2);
    CGContextTranslateCTM(newContext, -iamge_size.height/2, -iamge_size.width/2);
    
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:newImage];
    CGImageRelease(newImage);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    return image;
}

+(UIImage *)getRotatedImage:(UIImage *)sourceImage {
    
    const CGSize iamge_size = sourceImage.size;
    UIGraphicsBeginImageContext(iamge_size);
    [sourceImage drawInRect:CGRectMake(0, 0, iamge_size.width, iamge_size.height)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, iamge_size.width/2, iamge_size.height/2);
    CGContextRotateCTM(context, M_PI_2);
    CGContextTranslateCTM(context, -iamge_size.height/2, -iamge_size.width/2);
    CGImageRef rotatedImageRef = CGBitmapContextCreateImage(context);
    UIImage *outputImage = [[UIImage alloc] initWithCGImage:rotatedImageRef];
    CGImageRelease(rotatedImageRef);
    UIGraphicsEndImageContext();
    return outputImage;
    
}


+ (UIImage*)circleBrushTexture:(const CGFloat)circle_radius {
    UIImage *circleBrush = nil;
    
    UIGraphicsBeginImageContext(CGSizeMake(circle_radius * 2, circle_radius * 2));
    CGContextRef defBrushTextureContext = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(defBrushTextureContext);
    
    size_t num_locations = 3;
    CGFloat locations[3] = {0.0, 0.2, 1.0};
    CGFloat components[12] = {1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0};
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
    
    CGPoint myCentrePoint = CGPointMake(circle_radius, circle_radius);
    float myRadius = circle_radius - 2;
    
    CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                0, myCentrePoint, myRadius,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(myGradient);
    CGColorSpaceRelease(myColorspace);
    
    UIGraphicsPopContext();
    circleBrush = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return circleBrush;
}


+(UIImage *)squareBrushTexture:(const CGFloat)brush_size imageAlpha:(const CGFloat)alpha {
    UIGraphicsBeginImageContext(CGSizeMake(brush_size, brush_size));
    if(alpha == 0){
        [[UIColor clearColor] setFill];
    } else {
        [[[UIColor whiteColor] colorWithAlphaComponent:alpha] setFill];
    }
    UIImage *brush_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return brush_image;
}

+(UIImage *)circleAlphaImage:(const CGFloat)circle_radius imageAlpha:(const CGFloat)alpha {
    UIGraphicsBeginImageContext(CGSizeMake(2 * circle_radius, 2 * circle_radius));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 2 * circle_radius, 2 * circle_radius)];
    CGContextSetFillColorWithColor(context, [[[UIColor whiteColor] colorWithAlphaComponent:alpha] CGColor]);
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    CGContextClip(context);
    UIImage *brush_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return brush_image;
}

+(UIImage *)getSaturationBWImage:(UIImage *)sourceImage{
    
    CIImage *sourceCIImage = [[CIImage alloc] initWithImage:sourceImage];
    CIImage *grayImage = [sourceCIImage imageByApplyingFilter:@"CIColorControls"
                                    withInputParameters: @{kCIInputSaturationKey : @0.0}];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef grayImageRef = [context createCGImage:grayImage fromRect:grayImage.extent];
    UIImage *image = [[UIImage alloc] initWithCGImage:grayImageRef];
    CGImageRelease(grayImageRef);
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10){
        
    }

    return image;
}


+(CIImage *)getBlackAndWhiteExt:(UIImage *)sourceImage{
    CIImage *src_ci_image = [[CIImage alloc] initWithImage:sourceImage];
    CIFilter *colorControlFilter = [CIFilter filterWithName:@"CIColorControls"
                                              keysAndValues:kCIInputImageKey, src_ci_image,
                                    @"inputSaturation", [NSNumber numberWithFloat:0.0], nil];
    CIImage *bwCIImage = colorControlFilter.outputImage;
    src_ci_image = nil;
    return [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, bwCIImage,
            @"inputEV", [NSNumber numberWithFloat:1.1], nil].outputImage;
    
}

+(UIImage *)getMargedImage:(UIImage *)foregroundImage
            withBackground:(UIImage *)backgroundImage
                  inExtent:(const CGRect)sourceExtent{
    UIGraphicsBeginImageContext(sourceExtent.size);
    [[UIColor clearColor] setFill];
    [backgroundImage drawInRect:sourceExtent];
    [foregroundImage drawInRect:sourceExtent];
    UIImage *margedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return margedImage;
}




+(UIImage *)createIconImage:(UIImage *)sourceImage{
    const CGFloat maxWidth = sourceImage.size.width > sourceImage.size.height ? sourceImage.size.height : sourceImage.size.width;
    CGRect imageRect = CGRectMake(sourceImage.size.width / 2 - maxWidth / 2,
                                  sourceImage.size.height / 2 - maxWidth / 2,
                                  maxWidth, maxWidth);
    CGImageRef sourceImageRef = CGImageCreateWithImageInRect([sourceImage CGImage], imageRect);
    UIGraphicsBeginImageContext(CGSizeMake(300, 300));
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(contextRef, 0, 300);
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, 300, 300), sourceImageRef);
    UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(sourceImageRef);
    return iconImage;
}




+(UIImage*) getBlur:(UIImage*)theImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:35.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}











@end
