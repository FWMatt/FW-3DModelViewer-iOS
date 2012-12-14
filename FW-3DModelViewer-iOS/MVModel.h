//
//  MVModel.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 12/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import <vector>

@class MVGroup;

@interface MVModel : NSManagedObject {
    std::vector<MVGroup *> groups;
    GLuint geometryVBO, vertexCount;
    struct VertexGeometry *vertexGeometry;
}

@property (nonatomic, strong) NSString *modelDirectory,  *modelName;
@property (nonatomic, strong) NSString *thumbPath, *objPath;

@property (nonatomic, assign, readonly) CATransform3D normalisingTransform;

- (BOOL)load:(NSError * __autoreleasing *)error;
- (void)draw;

@end
