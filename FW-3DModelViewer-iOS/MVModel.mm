//
//  MVModel.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 12/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVModel.h"
#import "MVMaterial.h"
#import "MVVertex.h"
#import "MVFace.h"
#import "MVGroup.h"

#import <map>

#define OBJ_VERTEX @"v"
#define OBJ_TEX_COORD @"vt"
#define OBJ_NORMAL @"vn"
#define OBJ_FACE @"f"
#define OBJ_MTL_REF @"mtllib"
#define OBJ_GROUP @"g"
#define OBJ_USE_MAT @"usemtl"

#define MTL_NEWMAT @"newmtl"
#define MTL_AMBIENT_COL @"Ka"
#define MTL_DIFFUSE_COL @"Kd"
#define MTL_SPECULAR_COL @"Ks"
#define MTL_SHININESS @"Ns"

using namespace std;

@interface MVModel ()

@property (nonatomic, assign) CATransform3D normalisingTransform;
@property (nonatomic, strong) MVMaterial *material;
@property (nonatomic, strong, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSMutableDictionary *materials;
@property (nonatomic, strong, readonly) MVMaterial *defaultMaterial;

@end


@implementation MVModel

@dynamic objPath, thumbPath;
@dynamic modelName, modelDirectory;

@synthesize normalisingTransform = _normalisingTransform;
@synthesize material = _material;
@synthesize numberFormatter = _numberFormatter;
@synthesize defaultMaterial = _defaultMaterial;
@synthesize materials;

#pragma mark -
#pragma mark Loading

- (BOOL)load:(NSError * __autoreleasing *)error {
    return [self initWithOBJFile:self.objPath error:error];
}

#define numv(x) [self.numberFormatter numberFromString:x]
#define floatv(x) [numv(x) floatValue]
#define intv(x) [numv(x) intValue]


- (MVVertex *)vertexWithFaceInfo:(NSString *)faceInfo vertices:(vector<MVVertex *>&)vertices {
    NSArray *e = [faceInfo componentsSeparatedByString:@"/"];
    NSInteger i = intv(e[0]);
    if (i < 0)
        i += vertices.size();
    else
        --i;
    return vertices[i];
}

- (BOOL)initWithOBJFile:(NSString *)path error:(NSError * __autoreleasing *) error {

    const int32_t bufferSize = 4096;
    char buffer[bufferSize];
    FILE *fin = fopen(path.UTF8String, "r");
    if (!fin)
        return NO;
    
    self.materials = [NSMutableDictionary dictionary];
    vector<MVVertex *> vertices;
    MVGroup *group = [[MVGroup alloc] init];
    group.material = self.defaultMaterial;
    groups.push_back(group);
    
    CGFloat ext[6] = {-HUGE_VALF, -HUGE_VALF, -HUGE_VALF, HUGE_VALF, HUGE_VALF, HUGE_VALF};
    while (!feof(fin)) {
        if (fscanf(fin, "%[^\r\n]%*[\r\n]", buffer)) {
            @autoreleasepool {
                NSString *line = [NSString stringWithUTF8String:buffer];
                NSArray *v = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                if (!v.count)
                    continue;
                
                NSString *type = v[0];
                
                if ([type isEqualToString:OBJ_MTL_REF]) {
                    
                    if (v.count < 2)
                        return NO;
                    NSString *mtlPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:v[1]];
                    [self parseMTLFile:mtlPath];
                    
                } else if ([type isEqualToString:OBJ_VERTEX]) {
                    
                    if (v.count < 4)
                        return NO;
                    CGFloat x = floatv(v[1]), y = floatv(v[2]), z = floatv(v[3]);
                    ext[0] = MAX(ext[0], x); ext[1] = MAX(ext[1], y); ext[2] = MAX(ext[2], z);
                    ext[3] = MIN(ext[3], x); ext[4] = MIN(ext[4], y); ext[5] = MIN(ext[5], z);
                    
                    MVVertex *v = [[MVVertex alloc] initWithPosition:GLKVector3Make(x, y, z)];
                    vertices.push_back(v);
                    
                } else if ([type isEqualToString:OBJ_TEX_COORD]) {
                    
                    if (v.count < 3)
                        return NO;
//                    CGFloat x = floatv(v[1]), y = floatv(v[2]);
//                    texCoords.push_back(GLKVector2Make(x, y));
                    
                } else if ([type isEqualToString:OBJ_NORMAL]) {
                    
                    // We compute surface normals ourselves
                    
                } else if ([type isEqualToString:OBJ_FACE]) {
                    
                    if (v.count < 4)
                        return NO;
                    MVVertex *v1 = [self vertexWithFaceInfo:v[1] vertices:vertices];
                    for (NSInteger i = 2; i + 1 < v.count; ++i) {
                        MVVertex *v2 = [self vertexWithFaceInfo:v[i] vertices:vertices];
                        MVVertex *v3 = [self vertexWithFaceInfo:v[i + 1] vertices:vertices];
                        MVFace *f = [[MVFace alloc] initWithVertices:v1 :v2 :v3];
                        [group addFace:f];
                    }
                    
                } else if ([type isEqualToString:OBJ_GROUP]) {
                    group = [[MVGroup alloc] init];
                    if (v.count > 1)
                        group.name = v[1];
                    group.material = self.defaultMaterial;
                    groups.push_back(group);
                } else if ([type isEqualToString:OBJ_USE_MAT]) {
                    if (v.count < 1)
                        return NO;
                    NSString *materialName = v[1];
                    if ([self.materials.allKeys containsObject:materialName])
                        group.material = self.materials[materialName];
                }
            }
        }
    }
    fclose(fin);
    
    
    vertexCount = vertices.size();
    for (MVVertex *v : vertices)
        [v calculateNormal];
    
    vertexGeometry = (VertexGeometry *)malloc(vertices.size() * sizeof(VertexGeometry));
    map<MVVertex *, GLuint> vertexMap;
    GLuint i = 0;
    for (MVVertex * const v : vertices) {
        vertexMap[v] = i;
        vertexGeometry[i++] = v.geometry;
    }
    
    glGenBuffers(1, (GLuint *) &geometryVBO);
    
    for (MVGroup *g : groups)
        [g recalculateGeometryForVertexMap:vertexMap];
    
    CGFloat xd = ext[0] - ext[3], yd = ext[1] - ext[4], zd = ext[2] - ext[5];
    CGFloat norm[3] = { xd / 2.0f - ext[0], yd / 2.0f - ext[1], zd / 2.0f - ext[2] };
    const CGFloat scalingFactor = 1.6f;
    CGFloat scale = 1.0f / MAX(MAX(fabsf(xd), fabsf(yd)), fabsf(zd)) * scalingFactor;
    self->_normalisingTransform = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, scale, scale, scale), norm[0], norm[1], norm[2]);
    
    return YES;
}

- (void)parseMTLFile:(NSString *)path {
    const int32_t bufferSize = 4096;
    char buffer[bufferSize];
    FILE *fin = fopen(path.UTF8String, "r");
    if (!fin)
        return;
    
    MVMaterial *material = nil;
    while (fgets(buffer, sizeof buffer, fin)) {
        @autoreleasepool {
            NSString *line = [[[NSString stringWithUTF8String:buffer] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
            NSArray *v = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
            if (!v.count)
                continue;
            NSString *type = v[0];
            
            if ([type isEqualToString:MTL_NEWMAT]) {
                if (material)
                    self.materials[material.name] = material;
                material = [[MVMaterial alloc] init];
                material.name = v[1];
            } else if ([type isEqualToString:MTL_AMBIENT_COL]) {
                if (v.count < 4)
                    continue;
                CGFloat x = floatv(v[1]), y = floatv(v[2]), z = floatv(v[3]), w = 1.0f;
                if (v.count >= 5)
                    w = floatv(v[4]);
                material.ambient = GLKVector4Make(x, y, z, w);
            } else if ([type isEqualToString:MTL_DIFFUSE_COL]) {
                if (v.count < 4)
                    continue;
                CGFloat x = floatv(v[1]), y = floatv(v[2]), z = floatv(v[3]), w = 1.0f;
                if (v.count >= 5)
                    w = floatv(v[4]);
                material.diffuse = GLKVector4Make(x, y, z, w);
            } else if ([type isEqualToString:MTL_SPECULAR_COL]) {
                if (v.count < 4)
                    continue;
                CGFloat x = floatv(v[1]), y = floatv(v[2]), z = floatv(v[3]), w = 1.0f;
                if (v.count >= 5)
                    w = floatv(v[4]);
                material.specular = GLKVector4Make(x, y, z, w);
            } else if ([type isEqualToString:MTL_SHININESS]) {
                if (v.count < 2)
                    continue;
                material.shininess = floatv(v[1]);
            }
        }
    }
    fclose(fin);
    if (material)
        self.materials[material.name] = material;
}

#undef intv
#undef floatv
#undef numv


#pragma mark - Object Lifecycle

- (void)didTurnIntoFault {
    glDeleteBuffers(1, &geometryVBO);
    free(vertexGeometry);
    [super didTurnIntoFault];
}

- (NSNumberFormatter *)numberFormatter {
    if (!self->_numberFormatter) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.decimalSeparator = @".";
        self->_numberFormatter = numberFormatter;
    }
    return self->_numberFormatter;
}

- (MVMaterial *)defaultMaterial {
    if (!self->_defaultMaterial) {
        MVMaterial *material = [[MVMaterial alloc] init];
        material.ambient = GLKVector4Make(192.0f / 255.0f, 192.0f / 255.0f, 192.0f / 255.0f, 1.0f);
        material.diffuse = GLKVector4Make(192.0f / 255.0f, 192.0f / 255.0f, 192.0f / 255.0f, 1.0f);
        material.specular = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        material.shininess = 128.0f;
        self->_defaultMaterial = material;
    }
    return self->_defaultMaterial;
}

#pragma mark -
#pragma mark Drawing

- (void)draw {
    
    glEnable(GL_DEPTH_TEST);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    
    glBindBuffer(GL_ARRAY_BUFFER, geometryVBO);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(VertexGeometry), vertexGeometry, GL_DYNAMIC_DRAW);
    glVertexPointer(3, GL_FLOAT, sizeof(VertexGeometry), (GLvoid*) offsetof(VertexGeometry, position));
    glNormalPointer(GL_FLOAT, sizeof(VertexGeometry), (GLvoid *) offsetof(VertexGeometry, normal));
    
    for (MVGroup *group : groups)
        [group draw];

    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);

    glDisable(GL_DEPTH_TEST);
}


@end
