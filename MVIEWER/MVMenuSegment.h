//
//  MVMenuSegment.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 21/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVImageButton.h"

@interface MVMenuSegment : MVImageButton

- (id)initWithIndex:(NSInteger)index count:(NSInteger)count title:(NSString *)title;

@end
