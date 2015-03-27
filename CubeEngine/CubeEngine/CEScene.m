//
//  CEScene.m
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEScene.h"
#import "CECamera_Rendering.h"
#import "CERenderer.h"
#import "CECoordinateRenderer.h"

@interface CEScene () {
    CERenderer *_renderer;
    CECoordinateRenderer *_coordinateRenderer;
    NSMutableArray *_renderObjects;
}

@end

@implementation CEScene

- (instancetype)init
{
    self = [super init];
    if (self) {
        _renderObjects = [NSMutableArray array];
        
        _camera = [[CECamera alloc] init];
        _camera.radianDegree = 65;
        _camera.aspect = 320.0 / 568.0;
        _camera.nearZ = 0.1;
        _camera.farZ = 100;
        _camera.location = GLKVector3Make(0, 0, 4);
        
        _renderer = [CERenderer new];
        _renderer.backgroundColor = [UIColor whiteColor];
        
        _coordinateRenderer = [[CECoordinateRenderer alloc] initWithContext:_renderer.context];
        _coordinateRenderer.showWorldCoordinate = YES;
    }
    return self;
}

#pragma mark - Setters & Getters
- (EAGLContext *)context {
    return _renderer.context;
}

#pragma mark -
- (void)addRenderObject:(CEModel *)renderObject {
    if ([renderObject isKindOfClass:[CEModel class]]) {
        [_renderObjects addObject:renderObject];
        [_coordinateRenderer addModel:renderObject];
        
    } else {
        CEError(@"Can not add model to scene");
    }
}

- (void)removeRenderObject:(CEModel *)renderObject {
    if (renderObject) {
        [_renderObjects removeObject:renderObject];
        [_coordinateRenderer removeModel:renderObject];
    }
}


- (void)update {
    _renderer.cameraProjectionMatrix = _camera.projectionMatrix;
    [_renderer renderObjects:_renderObjects];
    
    _coordinateRenderer.cameraProjectionMatrix = _camera.projectionMatrix;
    [_coordinateRenderer render];
}


@end
