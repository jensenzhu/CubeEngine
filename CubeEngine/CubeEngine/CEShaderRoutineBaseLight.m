//
//  CEShaderRoutineBaseLight.m
//  CubeEngine
//
//  Created by chance on 8/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderRoutineBaseLight.h"

@implementation CEShaderRoutineBaseLight

-(NSString *)vertexShaderVariables {
    return CE_SHADER_STRING
    (
     struct LightInfo {
         bool IsEnabled;
         lowp int LightType; // 0:none 1:directional 2:point 3:spot
         mediump vec4 LightPosition;  // in eye space
         lowp vec3 LightDirection; // in eye space
         mediump vec3 LightColor;
         mediump float Attenuation;
         mediump float SpotConsCutoff;
         mediump float SpotExponent;
     };
     uniform LightInfo MainLight;
     
     attribute highp vec4 VertexPosition;
     attribute lowp vec3 VertexNormal;
     uniform lowp mat3 NormalMatrix;
     uniform lowp mat4 MVMatrix;
     uniform lowp vec3 EyeDirection; // in eye space
     
     varying lowp vec3 LightDirection;
     varying lowp vec3 EyeDirectionOut;
     varying lowp float Attenuation;
     varying lowp vec3 Normal;
     
     );
}


- (NSString *)vertexShaderImplementation {
    return CE_SHADER_STRING
    (
     // for locol lights, compute per fragment direction, halfVector and attenuation
     if (MainLight.LightType > 1) {
         LightDirection = vec3(MainLight.LightPosition) - vec3(MVMatrix * VertexPosition);
         float lightDistance = length(LightDirection);
         LightDirection = LightDirection / lightDistance; // normalize light direction
         
         Attenuation = 1.0 / (1.0 + MainLight.Attenuation * lightDistance + MainLight.Attenuation * lightDistance * lightDistance);
         if (MainLight.LightType == 3) { // spot light
             // lightDirection: current position to light position Direction
             // MainLight.LightDirection: source light direction, ref as ConeDirection
             float spotCos = dot(LightDirection, MainLight.LightDirection);
             if (spotCos < MainLight.SpotConsCutoff) {
                 Attenuation = 0.0;
             } else {
                 Attenuation *= pow(spotCos, MainLight.SpotExponent);
             }
         }
         
     } else { // directional light
         LightDirection = MainLight.LightDirection;
         Attenuation = 1.0;
     }
     EyeDirectionOut = EyeDirection;
     Normal = normalize(NormalMatrix * VertexNormal);
     
    );
}


- (NSString *)fragmentShaderVariables {
    return CE_SHADER_STRING
    (
     uniform vec3 SpecularColor;
     uniform vec3 AmbientColor;
     uniform float ShininessExponent;
     
     struct LightInfo {
         bool IsEnabled;
         lowp int LightType; // 0:none 1:directional 2:point 3:spot
         mediump vec4 LightPosition;  // in eys space
         lowp vec3 LightDirection; // in eye space
         mediump vec3 LightColor;
         mediump float Attenuation;
         mediump float SpotConsCutoff;
         mediump float SpotExponent;
     };
     uniform LightInfo MainLight;
     
     varying lowp vec3 LightDirection;
     varying lowp vec3 EyeDirectionOut;
     varying lowp float Attenuation;
     varying lowp vec3 Normal;
     
     required vec4 inputColor;
    );
}


- (NSString *)fragmentShaderImplementation {
    return CE_SHADER_STRING
    (
     lowp vec3 reflectDir = normalize(-reflect(LightDirection, normal));
     float diffuse = max(0.0, dot(normal, LightDirection));
     float specular = max(0.0, dot(reflectDir, EyeDirectionOut));
     specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
     vec3 scatteredLight = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;
     vec3 reflectedLight = SpecularColor * specular * Attenuation;
     
     inputColor = min(inputColor * scatteredLight + reflectedLight, vec4(1.0));
    );
}


@end





