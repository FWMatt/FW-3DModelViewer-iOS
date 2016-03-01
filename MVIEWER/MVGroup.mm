//
//  MVGroup.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 18/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVGroup.h"
#import "MVVertex.h"
#import "MVFace.h"

#import <map>

@implementation MVGroup

using namespace std;

- (void)recalculateGeometryForVertexMap:(std::map<MVVertex *, GLuint>&)vertexMap {
    if (faces.size()) {
        GLuint i = 0;
        indexes = (GLuint *)malloc(3 * faces.size() * sizeof(GLuint));
        for (MVFace * const f : faces) {
            indexes[i++] = vertexMap[f.vertices[0]];
            indexes[i++] = vertexMap[f.vertices[1]];
            indexes[i++] = vertexMap[f.vertices[2]];
        }
        
        if (indexesVBO != 0)
            glDeleteBuffers(1, &indexesVBO);
        glGenBuffers(1, (GLuint *) &indexesVBO);
    }
}

- (void)addFace:(MVFace *)face {
    faces.push_back(face);
}

- (void)draw {
    if (faces.size()) {

        [self.effect prepareToDraw];
        
        GLuint indexCount = (GLuint)(3 * faces.size());
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexesVBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(GLuint), indexes, GL_DYNAMIC_DRAW);
        
        glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_INT, 0);
    }
}

- (void)dealloc {
    if (faces.size()) {
        glDeleteBuffers(1, &indexesVBO);
    }
    free(indexes);
}

@end
