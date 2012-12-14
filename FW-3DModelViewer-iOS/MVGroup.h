//
//  MVGroup.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 18/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <vector>
#import <map>

@class MVVertex;
@class MVFace;
@class MVMaterial;

@interface MVGroup : NSObject {
    std::vector<MVFace *> faces;
    GLuint indexesVBO, *indexes;
}

@property (nonatomic, strong) MVMaterial *material;
@property (nonatomic, strong) NSString *name;

- (void)addFace:(MVFace *)face;

- (void)draw;
- (void)recalculateGeometryForVertexMap:(std::map<MVVertex *, GLuint>&)vertexMap;


@end
