//
//  CMImageExtension.h
//  ColorMagic
//
//  Created by Mostafizur Rahman on 11/9/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <GLKit/GLKit.h>

@interface CMImageExtension : NSObject

+ (UIImage *) imageFromCVImageBufferRef:(CVImageBufferRef)imageBuffer;

+ (UIImage *) getRotatedImage:(UIImage *)src_image;

+ (UIImage *) circleBrushTexture :(const CGFloat)circle_radius;
+ (UIImage *) circleAlphaImage   :(const CGFloat)circle_radius  imageAlpha:(const CGFloat)alpha;
+ (UIImage *) squareBrushTexture :(const CGFloat)brush_size     imageAlpha:(const CGFloat)alpha;

+ (UIImage *) getSaturationBWImage:(UIImage *)sourceImage;
+ (CIImage *) getBlackAndWhiteExt:(UIImage *)sourceImage;
+ (UIImage *) getMargedImage:(UIImage *)foregroundImage
            withBackground:(UIImage *)backgroundImage
                  inExtent:(const CGRect)sourceExtent;

+(UIImage *) createIconImage:(UIImage *)sourceImage;
+(UIImage*) getBlur:(UIImage*)theImage;
@end
