//
//  MVModel.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 12/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVESObject.h"
#import <CoreData/CoreData.h>
#import <vector>

@class MVGroup;

@interface MVModel : NSManagedObject<MVESObject> {
    std::vector<MVGroup *> groups;
    GLuint geometryVBO;
    size_t vertexCount;
    struct VertexGeometry *vertexGeometry;
}

@property (nonatomic, strong) NSString *modelDirectory,  *modelName;
@property (nonatomic, strong) NSString *objPath;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIImage *thumbnail;

- (BOOL)load:(NSError * __autoreleasing *)error;

@end
