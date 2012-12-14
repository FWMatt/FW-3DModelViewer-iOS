//
//  MVFace.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 18/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVFace.h"
#import "MVVertex.h"

@interface MVFace ()

@property (nonatomic, assign) GLKVector3 normal;

@end

@implementation MVFace

using namespace std;

- (id)initWithVertices: (MVVertex *)v1 : (MVVertex *)v2 : (MVVertex *)v3 {
    if ((self = [super init])) {
        vertices[0] = v1; vertices[1] = v2; vertices[2] = v3;
        [self calculateNormal];
        [v1 addFaceObject:self];
        [v2 addFaceObject:self];
        [v3 addFaceObject:self];
    }
    return self;
}


- (MVVertex * const __unsafe_unretained *) vertices {
    return vertices;
}

- (set<MVFace *>) neighbours {
    set<MVFace *> neighbours;
    const set<MVFace*> &f1 = vertices[0].faces;
    const set<MVFace*> &f2 = vertices[1].faces;
    const set<MVFace*> &f3 = vertices[2].faces;
    neighbours.insert(f1.begin(), f1.end());
    neighbours.insert(f2.begin(), f2.end());
    neighbours.insert(f3.begin(), f3.end());
    neighbours.erase(self);
    return neighbours;
}

- (void) calculateNormal {
    const GLKVector3 v1 = vertices[0].geometry.position;
    const GLKVector3 v2 = vertices[1].geometry.position;
    const GLKVector3 v3 = vertices[2].geometry.position;

    GLKVector3 u = GLKVector3Subtract(v2, v1);
    GLKVector3 v = GLKVector3Subtract(v3, v1);
    self->_normal = GLKVector3Normalize(GLKVector3CrossProduct(u, v));
}


@end
