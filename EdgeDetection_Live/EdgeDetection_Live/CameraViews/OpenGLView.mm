
#import "OpenGLView.h"
#import "GLShaderProgram.h"
#define TRIANGLE_INDEX_COUNT 6
typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

@interface OpenGLView(){
//    GLShaderProgram *shaderProgram;
    GLuint offscreenTexture;
    GLShaderProgram *quadProgram;
    GLShaderProgram *cameraProgram;
    GLShaderProgram *stickerProgram;
    GLShaderProgram *animationProgram;
    
    CGSize offscreenTextureSize;
    CGSize viewSize;
    
    GLubyte *pixelData;
    size_t dataLength;
}
@end

@implementation OpenGLView


const Vertex OffVertices[] = {
    {{1, -1, 0}, {1, 0, 0, 0.5}, {1, 1}},
    {{1, 1, 0}, {0, 1, 0, 0.4}, {1, 0}},
    {{-1, 1, 0}, {0, 0, 1, 0.3}, {0, 0}},
    {{-1, -1, 0}, {0, 0, 0, 0.2}, {0, 1}},
};
const GLubyte OffIndices[] = {
    0, 1, 2,
    2, 3, 0
};


const  Vertex CameraVertices[] = {
    {{1, 1, 0}, {1, 0, 0, 0.5}, {1, 1}},
    {{-1, 1, 0}, {0, 1, 0, 0.4}, {1, 0}},
    {{-1, -1, 0}, {0, 0, 1, 0.3}, {0, 0}},
    {{1, -1, 0}, {0, 0, 0, 0.2}, {0, 1}},
};

const GLubyte CameraIndices[] = {
    //Faces definition
    0, 1, 2,
    2, 3, 0          //Face front
    
};





const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 0.5}, {1, 1}},
    {{1, 1, 0}, {0, 1, 0, 0.4}, {1, 0}},
    {{-1, 1, 0}, {0, 0, 1, 0.3}, {0, 0}},
    {{-1, -1, 0}, {0, 0, 0, 0.2}, {0, 1}},
};
const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        offscreenTextureSize = CGSizeMake(1080, 1920); // same as img.png resolution, other small images will be scaled up linearly
    }
    return self;
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = NO;
    _eaglLayer.drawableProperties =
    [NSDictionary dictionaryWithObjectsAndKeys: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    [self setupLayer];
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    self.context = _context;
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    self.opaque = NO;
}

-(void)initializeRenderer:(const CGSize)tsize{
    offscreenTextureSize = tsize;
    dataLength = tsize.width * tsize.height * 4;
    pixelData = (GLubyte *)calloc(dataLength, sizeof(GLubyte *));
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        viewSize = CGSizeMake(self.bounds.size.width * self.contentScaleFactor,
                              self.bounds.size.height *  self.contentScaleFactor);
//    });
    
    
    [self setupFrameBuffer];
//    shaderProgram = [[GLShaderProgram alloc] initWithVS:@"QuadVProgram" FS:@"QuadFProgram"];
    quadProgram =  [[GLShaderProgram alloc] initWithVS:@"QuadVShader" FS:@"QuadFShader"];
    cameraProgram =  [[GLShaderProgram alloc] initWithVS:@"CameraVShader" FS:@"CameraFShader"];
    stickerProgram =  [[GLShaderProgram alloc] initWithVS:@"StickerVShader" FS:@"StickerFShader"];
//    animationProgram =  [[GLShaderProgram alloc] initWithVS:@"QuadVShader" FS:@"QuadFShader"];
    [self setupVBOs];
    
    [self generateTextures];
    [self renderTexture];
}

- (void)setupVBOs {
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &cam_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, cam_vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(CameraVertices), CameraVertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &cam_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cam_indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(CameraIndices), CameraIndices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &off_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, off_vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(OffVertices), OffVertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &off_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, off_indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(OffIndices), OffIndices, GL_STATIC_DRAW);
}

- (void)setupFrameBuffer {
    
    glGenFramebuffers(1, &frameBuffer);
    glGenTextures(1, &offscreenTexture);
    glGenRenderbuffers(1, &depthBuffer);
    
    glGenTextures(1, &offscreenTexture);
    glBindTexture(GL_TEXTURE_2D, offscreenTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, offscreenTextureSize.width, offscreenTextureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
    
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, offscreenTextureSize.width, offscreenTextureSize.height);

    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, offscreenTexture, 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
//
    
}

-(void)generateTextures{
    //    texture1 = [self setupTexture:@"cat.png"];
    //    texture2 = [self setupTexture:@"img.png"];
    //    texture3 = [self setupTexture:@"bw.jpg"];
    
    
    //camera texture
    
    textureSticker = [self setupTexture:@"eye_mask.png"];
    
    
    glGenTextures(1, &textureCamera);
    glBindTexture(GL_TEXTURE_2D, textureCamera);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)offscreenTextureSize.width, (int)offscreenTextureSize.height, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
    glGenTextures(1, &textureAnimBgr);
    glBindTexture(GL_TEXTURE_2D, textureAnimBgr);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)offscreenTextureSize.height, (int)offscreenTextureSize.width, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
    glGenTextures(1, &textureAnimFrm);
    glBindTexture(GL_TEXTURE_2D, textureAnimFrm);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)offscreenTextureSize.width, (int)offscreenTextureSize.height, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
//    glGenTextures(1, &textureSticker);
//    glBindTexture(GL_TEXTURE_2D, textureSticker);
//
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)600, (int)600, 0,
//                 GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
}

- (GLuint)setupTexture:(NSString *)imageName {
    // 1
    CGImageRef sourceImage = [UIImage imageNamed:imageName].CGImage;
    if (!sourceImage) {
        NSLog(@"Failed to load image %@", imageName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef imageContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4,
                                                      CGImageGetColorSpace(sourceImage),
                                                      kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), sourceImage);
    
    CGContextRelease(imageContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA , (int)width, (int)height, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}


//here is offscreen texture drawing.
-(void)renderTexture{
    
    [self bindDrawable];
    // 1. SAVE OUT THE DEFAULT FRAME BUFFER
    static GLint default_frame_buffer = 0;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &default_frame_buffer);
    
    // 2. RENDER TO OFFSCREEN RENDER TARGET
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    //    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    //    glBindTexture(GL_TEXTURE_2D, offscreenTexture);

    glViewport(0, 0, offscreenTextureSize.width, offscreenTextureSize.height);
    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    /// DRAW THE SCENE ///
    glUseProgram(cameraProgram.shaderHandle);
    glBindBuffer(GL_ARRAY_BUFFER, cam_vertexBuffer);
    glEnableVertexAttribArray(cameraProgram.a_TexturePosition);
    glVertexAttribPointer(cameraProgram.a_TexturePosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) offsetof(Vertex, Position));
    glEnableVertexAttribArray(cameraProgram.a_TextureCoordinate);
    glVertexAttribPointer(cameraProgram.a_TextureCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) offsetof(Vertex, TexCoord));
    
    glActiveTexture(GL_TEXTURE0+1);
    glBindTexture(GL_TEXTURE_2D, textureCamera);
    glProgramUniform1iEXT(cameraProgram.shaderHandle, cameraProgram.u_BaseTextureRGB, 1);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, offscreenTextureSize.width, offscreenTextureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixelData);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cam_indexBuffer);
    glDrawElements(GL_TRIANGLES, sizeof(CameraIndices)/sizeof(CameraIndices[0]), GL_UNSIGNED_BYTE, 0);
    
    glDisableVertexAttribArray(cameraProgram.a_TexturePosition);
    glDisableVertexAttribArray(cameraProgram.a_TextureCoordinate);
    
//    [self getImage:offscreenTextureSize];
//    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glUseProgram(stickerProgram.shaderHandle);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glEnableVertexAttribArray(stickerProgram.a_TexturePosition);
    glVertexAttribPointer(stickerProgram.a_TexturePosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) offsetof(Vertex, Position));
    glEnableVertexAttribArray(stickerProgram.a_TextureCoordinate);
    glVertexAttribPointer(stickerProgram.a_TextureCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) offsetof(Vertex, TexCoord));

    glActiveTexture(GL_TEXTURE0 + 2);
    glBindTexture(GL_TEXTURE_2D, textureSticker);
    glProgramUniform1iEXT(stickerProgram.shaderHandle, stickerProgram.u_BaseTextureRGB, 2);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, 0);
    [self getImage:offscreenTextureSize];
    glDisableVertexAttribArray(stickerProgram.a_TexturePosition);
    glDisableVertexAttribArray(stickerProgram.a_TextureCoordinate);
//
     //check GPU image for higher resultion. it should be 1080X1822
    
    
    // 3. RESTORE DEFAULT FRAME BUFFER
    glBindFramebuffer(GL_FRAMEBUFFER, default_frame_buffer);
    // 4. RENDER FULLSCREEN QUAD
    glViewport(0, 0, viewSize.width, viewSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUseProgram(quadProgram.shaderHandle);
    glBindBuffer(GL_ARRAY_BUFFER, off_vertexBuffer);
    glEnableVertexAttribArray(quadProgram.a_TexturePosition);
    glVertexAttribPointer(quadProgram.a_TexturePosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) offsetof(Vertex, Position));
    glEnableVertexAttribArray(quadProgram.a_TextureCoordinate);
    glVertexAttribPointer(quadProgram.a_TextureCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) offsetof(Vertex, TexCoord));
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, offscreenTexture);
    glUniform1i(quadProgram.u_BaseTextureRGB, 4);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, off_indexBuffer);
    glDrawElements(GL_TRIANGLES, sizeof(OffIndices)/sizeof(OffIndices[0]), GL_UNSIGNED_BYTE, 0);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    //    [self getImage:CGSizeMake( self.bounds.size.width * 2,  self.bounds.size.height * 2)]; // check gpu image for lower resolution
}

-(UIImage *)getImage:(CGSize)imageSize{
    NSUInteger length = imageSize.width * imageSize.height * 4;
    GLubyte * buffer = (GLubyte *)malloc(length * sizeof(GLubyte));
    if(buffer == NULL)
        return nil;
    glReadPixels(0, 0, imageSize.width, imageSize.height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, length, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * imageSize.width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(imageSize.width, imageSize.height, bitsPerComponent,
                                        bitsPerPixel, bytesPerRow, colorSpaceRef,
                                        bitmapInfo, provider, NULL, NO, renderingIntent);
    UIGraphicsBeginImageContext(imageSize);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),
                       CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), imageRef);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    free(buffer);
    return image;
}

-(void)updateCameraData:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    const unsigned char *imageBase = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
    memcpy(pixelData, imageBase, dataLength);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    [self renderTexture];
}
@end
