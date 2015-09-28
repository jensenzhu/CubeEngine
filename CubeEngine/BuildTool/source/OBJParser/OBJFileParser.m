//
//  ObjFileParser.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "OBJFileParser.h"
#import "CEVBOAttribute.h"

@implementation OBJFileParser {
    OBJFileInfo *_objInfo;
    NSMutableDictionary *_indicesDict;
}


+ (OBJFileParser *)parserWithFilePath:(NSString *)filePath {
    return [[OBJFileParser alloc] initWithFilePath:filePath];
}


- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
    }
    return self;
}


- (OBJFileInfo *)parse {
    NSError *error;
    NSString *objContent = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    /*
     NOTE: I use [... componentsSeparatedByString:@" "] to seperate because it's short writing,
     if something wrong, use [... componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet] instead.
     */
    
    
    _indicesDict = [NSMutableDictionary dictionary];
    
    NSString *fileName = [_filePath lastPathComponent];
    fileName = [fileName substringToIndex:fileName.length - 4];
    _objInfo = [[OBJFileInfo alloc] init];
    _objInfo.name = fileName;
    
    NSMutableArray *meshInfoList = [NSMutableArray array];
    MeshInfo *currentMesh = [MeshInfo new];
    currentMesh.groupNames = @[@"DefaultGroup"];
    currentMesh.indicesList = [NSMutableArray array];
    [meshInfoList addObject:currentMesh];
    
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    for (NSString *lineContent in lines) {
        // parse vertex "v 2.963007 0.335381 -0.052237"
        if ([lineContent hasPrefix:@"v "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            [_objInfo.positionList addVector3:[self vec3WithValueString:valueString]];
            continue;
        }
        
        // parse texture coordinate "vt 0.000000 1.000000"
        if ([lineContent hasPrefix:@"vt "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            [_objInfo.uvList addVector2:[self vec2WithValueString:valueString]];
            continue;
        }
        
        // parse normal "vn -0.951057 0.000000 0.309017"
        if ([lineContent hasPrefix:@"vn "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            [_objInfo.normalList addVector3:[self vec3WithValueString:valueString]];
            continue;
        }
        
        // parse group "g group1 pPipe1 group2"
        if ([lineContent hasPrefix:@"g "] || [lineContent hasPrefix:@"o "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            NSArray *groupNames = [valueString componentsSeparatedByString:@" "];
            MeshInfo *newMesh = [MeshInfo new];
            newMesh.groupNames = groupNames;
            newMesh.indicesList = [NSMutableArray array];
            [meshInfoList addObject:newMesh];
            currentMesh = newMesh;
            continue;
        }
        
        // parse faces "f 10/16/25 9/15/26 29/36/27 30/37/28"
        if ([lineContent hasPrefix:@"f "]) {
            NSString *content = [lineContent substringFromIndex:2];
            NSArray *indexStringList = [content componentsSeparatedByString:@" "];
            if (!_objInfo.attributes) {
                _objInfo.attributes = [self vertexAttributesWithFaceAttributes:indexStringList[0]];
            }
            
            if (indexStringList.count == 3) {
                for (NSString *indexString in indexStringList) {
                    [self appendIndexToMesh:currentMesh withIndexString:indexString];
                }
                
            } else if (indexStringList.count == 4) {
                // quadrilateral to triangle
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[0]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[1]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[3]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[3]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[1]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[2]];
            }
            continue;
        }
        
        // mtl file name
        if ([lineContent hasPrefix:@"mtllib"]) {
            _objInfo.mtlFileName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            continue;
        }
        
        // reference material
        if ([lineContent hasPrefix:@"usemtl"]) {
            currentMesh.materialName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            continue;
        }
    }
    
    // remove useless groups
    NSMutableArray *filteredMeshes = [NSMutableArray array];
    for (MeshInfo *mesh in meshInfoList) {
        if (mesh.groupNames.count && mesh.indicesList.count) {
            [filteredMeshes addObject:mesh];
        }
    }
    _objInfo.meshInfos = filteredMeshes.copy;
    OBJFileInfo *returnInfo = _objInfo;
    
    // clean up
    _indicesDict = nil;
    _objInfo = nil;
    
    return returnInfo;
}


#pragma mark - Element Extract

- (NSData *)dataWithFloatStringList:(NSArray *)floatStringList {
    NSMutableData *valueData = [NSMutableData data];
    for (NSString *floatString in floatStringList) {
        float value = [floatString floatValue];
        [valueData appendBytes:&value length:sizeof(float)];
    }
    return valueData;
}


// 根据索引获取对应的坐标，纹理，法线等值，组成NSData返回
- (void)appendIndexToMesh:(MeshInfo *)mesh withIndexString:(NSString *)indexString {
    NSArray *indies = [indexString componentsSeparatedByString:@"/"];
    __block unsigned int positionIndex = -1, uvIndex = -1, normalIndex = -1;
    [indies enumerateObjectsUsingBlock:^(NSString *indexString, NSUInteger idx, BOOL *stop) {
        if (indexString.length) {
            int index = [indexString intValue] - 1;
            if (index >= 0) {
                switch (idx) {
                    case 0: { // position
                        positionIndex = index;
                        break;
                    }
                    case 1: { // texture coordinate
                        uvIndex = index;
                        break;
                    }
                    case 2: { // normal
                        normalIndex = index;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }];
    
    NSNumber *index = _indicesDict[indexString];
    unsigned short u_index;
    if (index) {
        u_index = [index unsignedShortValue];
    } else {
        u_index = _objInfo.vertexDataList.count;
        _indicesDict[indexString] = @(u_index);
        [_objInfo.vertexDataList addVector3:GLKVector3Make(positionIndex, uvIndex, normalIndex)];
        NSAssert((_indicesDict.count == _objInfo.vertexDataList.count), @"wrong index");
    }
    mesh.maxIndex = MAX(mesh.maxIndex, u_index);
    [mesh.indicesList addObject:@(u_index)];
}


- (NSArray *)vertexAttributesWithFaceAttributes:(NSString *)attributeString {
    NSArray *indices = [attributeString componentsSeparatedByString:@"/"];
    NSMutableArray *attributeNames = [NSMutableArray arrayWithCapacity:indices.count];
    if (indices.count >= 1) { // add position
        [attributeNames addObject:@(CEVBOAttributePosition)];
    }
    if (indices.count >= 2) {
        if ([indices[1] length]) {
            [attributeNames addObject:@(CEVBOAttributeTextureCoord)];
        } else {
            [attributeNames addObject:@(CEVBOAttributeNormal)];
        }
    }
    if (indices.count >= 3 && [indices[1] length]) {
        [attributeNames addObject:@(CEVBOAttributeNormal)];
    }
    
    return attributeNames;
}


// calcualte tengent data
+ (BOOL)addTengentDataToObjInfo:(OBJFileInfo *)objInfo {
    if (!objInfo.vertexDataList.count ||
        ![objInfo.attributes containsObject:@(CEVBOAttributePosition)] ||
        ![objInfo.attributes containsObject:@(CEVBOAttributeNormal)]) {
        printf("Fail to calculate tangent data for obj file:%s\n", [objInfo.name UTF8String]);
        return NO;
    }
    
    // erase old normal and tangent data
    objInfo.normalList = [[VectorList alloc] initWithVectorType:VectorType3];
    objInfo.tangentList = [[VectorList alloc] initWithVectorType:VectorType3];
    
    // calucate each triangle's normal and tangent data
    for (MeshInfo *meshInfo in objInfo.meshInfos) {
        if (!meshInfo.indicesList.count % 3) {
            printf("warning: skip mesh with wrong indice count\n");
            continue;
        }
        // loop triangles
        int triangleCount = (int)meshInfo.indicesList.count / 3;
        for (int i = 0; i < triangleCount; i += 3) {
            printf("%d, ", i);
            GLKVector3 idx0 = [objInfo.vertexDataList vector3AtIndex:[meshInfo.indicesList[i] intValue]];
            GLKVector3 idx1 = [objInfo.vertexDataList vector3AtIndex:[meshInfo.indicesList[i + 1] intValue]];
            GLKVector3 idx2 = [objInfo.vertexDataList vector3AtIndex:[meshInfo.indicesList[i + 2] intValue]];
            
            // calculate normal vector
            GLKVector3 v1 = GLKVector3Subtract(vertex0.position, vertex1.position);
            GLKVector3 v2 = GLKVector3Subtract(vertex0.position, vertex2.position);
            GLKVector3 normal = GLKVector3CrossProduct(v1, v2);
            normal = GLKVector3Normalize(normal);
            
            // smooth normals
            vertex0.normal = GLKVector3Add(vertex0.normal, normal);
            vertex1.normal = GLKVector3Add(vertex1.normal, normal);
            vertex2.normal = GLKVector3Add(vertex2.normal, normal);
            
//            // tangent
//            GLKVector2 uv1 = GLKVector2Subtract(vertex2.uv, vertex0.uv);
//            GLKVector2 uv2 = GLKVector2Subtract(vertex1.uv, vertex0.uv);
//            GLKVector3 tangent;
//            float c = 1.0f / (uv1.x * uv2.y - uv2.x * uv1.y);
//            tangent.x = (v1.x * uv2.y + v2.x * uv1.y) * c;
//            tangent.y = (v1.y * uv2.y + v2.y * uv1.y) * c;
//            tangent.z = (v1.z * uv2.y + v2.z * uv1.y) * c;
//            vertex0.tangent = GLKVector3Add(vertex0.tangent, tangent);
//            vertex1.tangent = GLKVector3Add(vertex1.tangent, tangent);
//            vertex2.tangent = GLKVector3Add(vertex2.tangent, tangent);
        }
    }
    
    return YES;
}


#pragma mark - 
// "-0.951057 0.309017" -> GLKVector2
- (GLKVector2)vec2WithValueString:(NSString *)valueString {
    NSArray *values = [valueString componentsSeparatedByString:@" "];
    NSAssert(values.count >= 2, @"wrong vec2 string");
    return GLKVector2Make([values[0] floatValue], [values[1] floatValue]);
}

// "-0.951057 0.00000 0.309017" -> GLKVector3
- (GLKVector3)vec3WithValueString:(NSString *)valueString {
    NSArray *values = [valueString componentsSeparatedByString:@" "];
    NSAssert(values.count >= 3, @"wrong vec3 string");
    return GLKVector3Make([values[0] floatValue], [values[1] floatValue], [values[2] floatValue]);
}


@end











