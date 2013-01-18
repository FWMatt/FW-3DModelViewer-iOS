//
//  MVVertex.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 18/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVVertex.h"
#import "MVFace.h"

@implementation MVVertex


- (id)initWithPosition:(GLKVector3)position {
    if ((self = [super init])) {
        geometry.position = position;
    }
    return self;
}

- (const std::set<MVFace *> &) faces {
    return faces;
}

- (VertexGeometry &) geometry {
    return geometry;
}

- (void)addFaceObject:(MVFace *)face {
    faces.insert(face);
}

- (void)calculateNormal {
    geometry.normal = GLKVector3Make(.0f, .0f, .0f);
    for (MVFace * const face : faces)
        geometry.normal = GLKVector3Add(geometry.normal, face.normal);
    geometry.normal = GLKVector3Normalize(geometry.normal);
}

@end
