//
//  MVModel.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 12/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVModel.h"
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
#define MTL_AMBIENT_TEX @"map_Ka"
#define MTL_DIFFUSE_TEX @"map_Kd"
#define MTL_SPECULAR_TEX @"map_Ks"

using namespace std;

@interface MVModel ()

@property (nonatomic, strong, readonly) NSNumberFormatter *numberFormatter;

@property (nonatomic, strong) NSMutableDictionary *effects;
@property (nonatomic, strong) NSMutableArray *textures;
@property (nonatomic, strong, readonly) GLKBaseEffect *defaultEffect;

@property (nonatomic, assign) GLKVector3 scale, translation;

+ (GLKBaseEffect *)baseEffect;

@end


@implementation MVModel

@dynamic objPath;
@dynamic modelName, modelDirectory;

@synthesize defaultEffect = _defaultEffect, effects = _effects;
@synthesize scale = _scale, translation = _translation;
@synthesize textures = _textures;
@synthesize numberFormatter = _numberFormatter;

@synthesize thumbnail = _thumbnail;

#pragma mark -
#pragma mark Loading

- (BOOL)load:(NSError * __autoreleasing *)error {
    return [self initWithOBJFile:self.objPath error:error];
}

#define numv(x) [self.numberFormatter numberFromString:x]
#define floatv(x) [numv(x) floatValue]
#define intv(x) [numv(x) intValue]


- (MVVertex *)vertexWithFaceInfo:(NSString *)faceInfo vertices:(vector<MVVertex *>&)vertices texCoords:(vector<GLKVector2> &)texCoords {
    NSArray *e = [faceInfo componentsSeparatedByString:@"/"];
    NSInteger i = intv(e[0]);
    if (i < 0)
        i += vertices.size();
    else
        --i;
    MVVertex *v = vertices[i];
    if (e.count > 1 && [e[1] length]) {
        NSInteger ti = intv(e[1]);
        if (ti < 0)
            ti += texCoords.size();
        else
            --ti;
        GLKVector2 texCoord = texCoords[ti];
        v.geometry.texCoord = texCoord;
    }
    return vertices[i];
}

- (BOOL)initWithOBJFile:(NSString *)path error:(NSError * __autoreleasing *) error {

    const int32_t bufferSize = 4096;
    char buffer[bufferSize];
    FILE *fin = fopen(path.UTF8String, "r");
    if (!fin)
        return NO;
    
    self.effects = [NSMutableDictionary dictionary];
    self.textures = [NSMutableArray array];
    vector<MVVertex *> vertices;
    vector<GLKVector2> texCoords;
    MVGroup *group = [[MVGroup alloc] init];
    group.effect = self.defaultEffect;
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
                    CGFloat x = floatv(v[1]), y = floatv(v[2]);
                    if (x > 1 || x < 0)
                        x = fmod(x, 1);
                    if (y > 1 || y < 0)
                        y = fmod(y, 1);
                    texCoords.push_back(GLKVector2Make(x, y));
                    
                } else if ([type isEqualToString:OBJ_NORMAL]) {
                    
                    // We compute surface normals ourselves
                    
                } else if ([type isEqualToString:OBJ_FACE]) {
                    
                    if (v.count < 4)
                        return NO;
                    MVVertex *v1 = [self vertexWithFaceInfo:v[1] vertices:vertices texCoords:texCoords];
                    for (NSInteger i = 2; i + 1 < v.count; ++i) {
                        MVVertex *v2 = [self vertexWithFaceInfo:v[i] vertices:vertices texCoords:texCoords];
                        MVVertex *v3 = [self vertexWithFaceInfo:v[i + 1] vertices:vertices texCoords:texCoords];
                        MVFace *f = [[MVFace alloc] initWithVertices:v1 :v2 :v3];
                        [group addFace:f];
                    }
                    
                } else if ([type isEqualToString:OBJ_GROUP]) {
                    group = [[MVGroup alloc] init];
                    if (v.count > 1)
                        group.name = v[1];
                    group.effect = self.defaultEffect;
                    groups.push_back(group);
                } else if ([type isEqualToString:OBJ_USE_MAT]) {
                    if (v.count < 1)
                        return NO;
                    NSString *effectLabel = v[1];
                    if ([self.effects.allKeys containsObject:effectLabel])
                        group.effect = self.effects[effectLabel];
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
    
    CGFloat scale = 1.0f / MAX(MAX(fabsf(xd), fabsf(yd)), fabsf(zd));
    self.scale = GLKVector3Make(scale, scale, scale);
    self.translation = GLKVector3Make(xd / 2.0f - ext[0], yd / 2.0f - ext[1], zd / 2.0f - ext[2]);
    
    return YES;
}

- (void)setProjectionMatrix:(GLKMatrix4)projection {
    self.defaultEffect.transform.projectionMatrix = projection;
    for (GLKBaseEffect *e in self.effects.allValues)
        e.transform.projectionMatrix = projection;
}

- (void)setModelviewMatrix:(GLKMatrix4)modelview {
    GLKMatrix4 m = GLKMatrix4TranslateWithVector3(GLKMatrix4ScaleWithVector3(modelview, self.scale), self.translation);
    self.defaultEffect.transform.modelviewMatrix = m;
    for (GLKBaseEffect *e in self.effects.allValues)
        e.transform.modelviewMatrix = m;
}

- (void)parseMTLFile:(NSString *)path {
    const int32_t bufferSize = 4096;
    char buffer[bufferSize];
    FILE *fin = fopen(path.UTF8String, "r");
    if (!fin)
        return;
    
    GLKBaseEffect *effect = nil;
    while (fgets(buffer, sizeof buffer, fin)) {
        @autoreleasepool {
            NSString *line = [[[NSString stringWithUTF8String:buffer] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
            NSArray *v = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
            if (!v.count)
                continue;
            NSString *type = v[0];
            
            if ([type isEqualToString:MTL_NEWMAT]) {
                if (effect)
                    self.effects[effect.label] = effect;
                effect = [MVModel baseEffect];
                effect.label = v[1];
            } else if ([type isEqualToString:MTL_AMBIENT_COL]) {
                if (v.count < 4)
                    continue;
                CGFloat x = floatv(v[1]), y = floatv(v[2]), z = floatv(v[3]), w = 1.0f;
                if (v.count >= 5)
                    w = floatv(v[4]);
                effect.material.ambientColor = GLKVector4Make(x, y, z, w);
            } else if ([type isEqualToString:MTL_DIFFUSE_COL]) {
                if (v.count < 4)
                    continue;
                CGFloat x = floatv(v[1]), y = floatv(v[2]), z = floatv(v[3]), w = 1.0f;
                if (v.count >= 5)
                    w = floatv(v[4]);
                effect.material.diffuseColor = GLKVector4Make(x, y, z, w);
            } else if ([type isEqualToString:MTL_SPECULAR_COL]) {
                if (v.count < 4)
                    continue;
                CGFloat x = floatv(v[1]), y = floatv(v[2]), z = floatv(v[3]), w = 1.0f;
                if (v.count >= 5)
                    w = floatv(v[4]);
                effect.material.specularColor = GLKVector4Make(x, y, z, w);
            } else if ([type isEqualToString:MTL_SHININESS]) {
                if (v.count < 2)
                    continue;
                effect.material.shininess = MAX(floatv(v[1]), 1.0f);
            } else if ([type isEqualToString:MTL_AMBIENT_TEX]) {
                if (v.count < 2)
                    continue;
                // TODO properly handle ambient, diffuse and specular texture channels

            } else if ([type isEqualToString:MTL_DIFFUSE_TEX]) {
                if (v.count < 2)
                    continue;
                NSString *texPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:v[1]];
                UIImage *image = [UIImage imageWithContentsOfFile:texPath];
                GLKTextureInfo *texture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:NULL];
                [self.textures addObject:texture];
                effect.texture2d0.envMode = GLKTextureEnvModeReplace;
                effect.texture2d0.target = GLKTextureTarget2D;
                effect.texture2d0.name = texture.name;
            } else if ([type isEqualToString:MTL_SPECULAR_TEX]) {
                if (v.count < 2)
                    continue;
                // TODO properly handle ambient, diffuse and specular texture channels
            }
        }
    }
    fclose(fin);
    if (effect)
        self.effects[effect.label] = effect;
}

#undef intv
#undef floatv
#undef numv

#pragma mark - Effects

- (GLKBaseEffect *)defaultEffect {
    if (!self->_defaultEffect) {
        GLKBaseEffect *e = [MVModel baseEffect];
        e.material.ambientColor = GLKVector4Make(192.0f / 255.0f, 192.0f / 255.0f, 192.0f / 255.0f, 1.0f);
        e.material.diffuseColor = GLKVector4Make(192.0f / 255.0f, 192.0f / 255.0f, 192.0f / 255.0f, 1.0f);
        e.material.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        e.material.shininess = 128.0f;
        self->_defaultEffect = e;
    }
    return self->_defaultEffect;
}

+ (GLKBaseEffect *)baseEffect {
    GLKBaseEffect *e = [[GLKBaseEffect alloc] init];
    e.light0.enabled = YES;
    e.light0.ambientColor = GLKVector4Make(0.125f, 0.125f, 0.125f, 1.0f);
    e.light0.diffuseColor = GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f);
    e.light0.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    e.light0.position = GLKVector4Make(.0f, 2.0f, 2.0f, .0f);
    return e;
}

#pragma mark - Object Lifecycle

- (void)setThumbnail:(UIImage *)thumbnail {
    NSString *path = [self.modelDirectory stringByAppendingPathComponent:@"thumbnail.png"];
    NSData *data = UIImagePNGRepresentation(thumbnail);
    [data writeToFile:path atomically:YES];
    self->_thumbnail = thumbnail;
}

- (UIImage *)thumbnail {
    if (!self->_thumbnail) {
        NSString *path = [self.modelDirectory stringByAppendingPathComponent:@"thumbnail.png"];
        self->_thumbnail = [UIImage imageWithContentsOfFile:path];
    }
    return self->_thumbnail;
}

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

#pragma mark -
#pragma mark Drawing

- (void)draw {
        
    glEnable(GL_DEPTH_TEST);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    glBindBuffer(GL_ARRAY_BUFFER, geometryVBO);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(VertexGeometry), vertexGeometry, GL_DYNAMIC_DRAW);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexGeometry), (GLvoid *)offsetof(VertexGeometry, position));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(VertexGeometry), (GLvoid *) offsetof(VertexGeometry, normal));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexGeometry), (GLvoid *) offsetof(VertexGeometry, texCoord));
    
    for (MVGroup *group : groups)
        [group draw];

    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribNormal);
    glDisableVertexAttribArray(GLKVertexAttribPosition);

    glDisable(GL_DEPTH_TEST);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


@end
