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
    
    return self;
}
@end
