//
//  OpenGLView.h
//  DrawingTest
//
//  Created by Mostafizur Rahman on 10/25/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIDevice.h>
#import <CoreImage/CoreImage.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <CoreImage/CIDetector.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface OpenGLView : GLKView{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    
    GLuint programHandle;
    
    GLuint _textureUniform;
    
    GLuint _positionSlot;
    GLuint _texCoordSlot;
    
    GLuint _floorTexture;
    
    GLuint resolution;
    GLuint blur_radius;
    GLuint direction;
    
    GLuint vertexBuffer;
    GLuint indexBuffer;
    
    GLuint off_vertexBuffer;
    GLuint off_indexBuffer;
    
    GLuint cam_vertexBuffer;
    GLuint cam_indexBuffer;
    
    GLuint frameBuffer;
    GLuint frameBuffer1;
    GLuint frameBuffer2;
    
    GLuint textureCamera;
    GLuint textureAnimBgr;
    GLuint textureAnimFrm;
    GLuint textureSticker;
    GLuint renderBuffer;
    GLuint depthBuffer;
    GLuint depthBuffer1;
    GLuint depthBuffer2;
    
    GLuint u_BaseTextureRGB;
    GLuint u_TextureBackground;
    GLuint u_TextureFrame;
    GLuint a_TexturePosition;
    GLuint a_TextureCoordinate;
    
    
}
-(void)updateCameraData:(CMSampleBufferRef)sampleBuffer;
-(void)renderTexture;
-(void)initializeRenderer:(const CGSize)tsize;
-(void) setupContext ;
@end
