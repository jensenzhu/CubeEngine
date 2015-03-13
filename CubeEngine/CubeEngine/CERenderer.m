//
//  CERenderer.m
//  CubeEngine
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CETestProgram.h"
#import "CEModel_Rendering.h"

@implementation CERenderer {
    CETestProgram *_program;
    
    // clear color
    CGFloat _clearColorRed;
    CGFloat _clearColorGreen;
    CGFloat _clearColorBlue;
    CGFloat _clearColorAlpha;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupOpenGL];
    }
    return self;
}


- (void)setupOpenGL {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            CEError("Fail to init context");
            return;
        }
    }
    
    [EAGLContext setCurrentContext:_context];
    
    _program = [CETestProgram defaultProgram];
    if (![_program link]) {
        _program = nil;
        CEError(@"Fail to setup program");
        
    } else {
        CELog(@"Setup program OK");
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        [_backgroundColor getRed:&_clearColorRed
                           green:&_clearColorGreen
                            blue:&_clearColorBlue
                           alpha:&_clearColorAlpha];
    }
}


- (void)renderObject:(CEModel *)object {
    if (!object || !_program) {
        CEError(@"Can not render object");
        return;
    }
    [EAGLContext setCurrentContext:_context];
    
    // set background
    glClearColor(_clearColorRed, _clearColorGreen, _clearColorBlue, _clearColorAlpha);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    
    
    // check vertex buffer
    if (!object.vertexBufferIndex) {
        [object generateVertexBufferInContext:_context];
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, object.vertexBufferIndex);
    glEnableVertexAttribArray(_program.attributePosotion);
    glVertexAttribPointer(_program.attributePosotion, 3, GL_FLOAT, GL_FALSE, 24, CE_BUFFER_OFFSET(0));
    [_program use];
    
    // TODO:render object with different programs
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_cameraProjectionMatrix, object.transformMatrix);
    glUniformMatrix4fv(_program.uniformProjection, 1, 0, projectionMatrix.m);
    
    glUniform4f(_program.uniformDrawColor, 0.6, 0.6, 0.6, 1.0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glUniform4f(_program.uniformDrawColor, 1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_LINE_STRIP, 0, 36);
}


- (void)renderObjects:(NSArray *)objects {
    if (!objects.count || !_program) {
        CEError(@"Can not render object");
        return;
    }
    [EAGLContext setCurrentContext:_context];
    
    // set background
    glClearColor(_clearColorRed, _clearColorGreen, _clearColorBlue, _clearColorAlpha);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // enable depth test
    glEnable(GL_DEPTH_TEST);
//        glDepthMask(GL_TRUE);
//        glDepthFunc(GL_LEQUAL);
//        glDepthRangef(0.0f, 1.0f);
    
    for (CEModel *object in objects) {
        // check vertex buffer
        if (!object.vertexBufferIndex) {
            [object generateVertexBufferInContext:_context];
        }
        
        glBindBuffer(GL_ARRAY_BUFFER, object.vertexBufferIndex);
        glEnableVertexAttribArray(_program.attributePosotion);
        glVertexAttribPointer(_program.attributePosotion, 3, GL_FLOAT, GL_FALSE, 24, CE_BUFFER_OFFSET(0));
        [_program use];
        
        // TODO:render object with different programs
        GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_cameraProjectionMatrix, object.transformMatrix);
        glUniformMatrix4fv(_program.uniformProjection, 1, 0, projectionMatrix.m);
        
        if (objects.lastObject == object) {
            glUniform4f(_program.uniformDrawColor, 0.6, 0.6, 0.6, 1.0);
        } else {
            glUniform4f(_program.uniformDrawColor, 0.6, 0.0, 0.6, 1.0);
        }
        
        glDrawArrays(GL_TRIANGLES, 0, object.vertextCount);
        
        glUniform4f(_program.uniformDrawColor, 0.5, 0.5, 0.5, 1.0);
        glLineWidth(2.0f);
        glDrawArrays(GL_LINE_STRIP, 0, object.vertextCount);
    }
}



@end
