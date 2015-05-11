//
//  CERenderer_Accessory.h
//  CubeEngine
//
//  Created by chance on 4/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CELight.h"

/**
 Use to render accessory info of the model, like bounds, local coordinate indicator
 */
@interface CEAssistRenderer : CERenderer

- (void)renderLights:(NSSet *)lights;

- (void)renderWorldOriginCoordinate;

@end
