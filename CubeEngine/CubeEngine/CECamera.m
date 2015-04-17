//
//  CECamera.m
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CECamera.h"
#import "CECamera_Rendering.h"

@implementation CECamera {
    GLKMatrix4 _projectionMatrix;
    BOOL _perspectiveChanged;
    
//    GLKQuaternion _lookAtQuaternion;
//    BOOL _lookAtChanged;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _projectionType = CEProjectionPerpective;
        _perspectiveChanged = YES;
    }
    return self;
}

#pragma mark - Setter & Getters 
- (void)setProjectionType:(CEProjectionType)projectionType {
    if (_projectionType != projectionType) {
        _projectionType = projectionType;
        _perspectiveChanged = YES;
    }
}

- (void)setRadianDegree:(float)radianDegree {
    if (_radianDegree != radianDegree) {
        _radianDegree = radianDegree;
        _perspectiveChanged = YES;
    }
}

- (void)setAspect:(float)aspect {
    if (_aspect != aspect) {
        _aspect = aspect;
        _perspectiveChanged = YES;
    }
}

- (void)setNearZ:(float)nearZ {
    if (_nearZ != nearZ) {
        _nearZ = nearZ;
        _perspectiveChanged = YES;
    }
}

- (void)setFarZ:(float)farZ {
    if (_farZ != farZ) {
        _farZ = farZ;
        _perspectiveChanged = YES;
    }
}

#pragma mark - Rotation

- (void)lookAt:(GLKVector3)targetLocation {
    GLKMatrix4 lookAtMatrix = GLKMatrix4MakeLookAt(self.position.x, self.position.y, self.position.z, targetLocation.x, targetLocation.y, targetLocation.z, 0, 1, 0);
    lookAtMatrix = GLKMatrix4Invert(lookAtMatrix, NULL);
    GLKQuaternion lookAtQuaternion = GLKQuaternionMakeWithMatrix4(lookAtMatrix);
    self.rotation = lookAtQuaternion;
}


// !!!: Overwrite transformMatrix
- (GLKMatrix4)transformMatrix {
    if (_hasChanged) {
        // update local transfrom matrix
        GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(_position.x, _position.y, _position.z);
        tranformMatrix = GLKMatrix4Multiply(tranformMatrix, GLKMatrix4MakeWithQuaternion(_rotation));
        tranformMatrix = GLKMatrix4ScaleWithVector3(tranformMatrix, _scale);
        _transformMatrix = tranformMatrix;
        _hasChanged = NO;
    }
    
    if (_parentObject) {
        return GLKMatrix4Invert(GLKMatrix4Multiply(_parentObject.transformMatrix, _transformMatrix), NULL);
        
    } else {
        return GLKMatrix4Invert(_transformMatrix, NULL);
    }
}


- (GLKMatrix4)projectionMatrix {
    if (!_perspectiveChanged) {
        return _projectionMatrix;
    }
    
//    GLKMatrix4 transformMatrix = GLKMatrix4MakeWithQuaternion(_lookAtQuaternion);
//    transformMatrix = GLKMatrix4Multiply(transformMatrix, [self transformMatrix]);
//    _lookAtChanged = NO;
    
    if (_perspectiveChanged) {
        if (_projectionType == CEProjectionPerpective) {
            _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_radianDegree), _aspect, _nearZ, _farZ);
            
        } else if (_projectionType == CEProjectionOrthographic) {
            _projectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1 / _aspect, 1 / _aspect, _nearZ, _farZ);
            
        } else {
            CEError(@"Error: Unknown projection type");
            _projectionMatrix = GLKMatrix4Identity;
        }
        _perspectiveChanged = NO;
    }
    
    return _projectionMatrix;
}

- (GLKMatrix4)viewMatrix {
    return [self transformMatrix];
}


@end


