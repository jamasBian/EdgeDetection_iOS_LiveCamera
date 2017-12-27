//
//  BlurShaderProgram.m
//  EdgeDetection_Live
//
//  Created by Paradox Lab on 12/27/17.
//  Copyright © 2017 Paradox Lab. All rights reserved.
//

#import "BlurShaderProgram.h"

@implementation BlurShaderProgram
-(instancetype)initWithVS:(NSString *)vs FS:(NSString *)fs{
    self = [super initWithVS:vs FS:fs];
    self.u_TexelWidthOffset = glGetUniformLocation(self.shaderHandle, "texelWidthOffset");
    self.u_texelHeightOffset = glGetUniformLocation(self.shaderHandle, "texelHeightOffset");
    
    self.u_resolution =  glGetUniformLocation(self.shaderHandle, "resolution");
    self.u_blur_radius =  glGetUniformLocation(self.shaderHandle, "blur_radius");
    self.u_direction =  glGetUniformLocation(self.shaderHandle, "direction");
    
    return self;
}
@end
