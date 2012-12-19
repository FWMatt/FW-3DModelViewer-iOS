//
//  MVFace.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 18/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <set>

@class MVVertex;

@interface MVFace : NSObject {
    __strong MVVertex *vertices[3];
}

@property (nonatomic, assign, readonly) GLKVector3 normal;
@property (nonatomic, assign, readonly) MVVertex * const *vertices;

- (id)initWithVertices: (MVVertex *)v1 : (MVVertex *)v2 : (MVVertex *)v3;

- (std::set<MVFace *>) neighbours;

- (void) calculateNormal;

@end
