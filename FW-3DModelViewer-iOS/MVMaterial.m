//
//  MVMaterial.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 17/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVMaterial.h"

@implementation MVMaterial

- (void)setShininess:(CGFloat)shininess {
    self->_shininess = MAX(shininess, 1.0f);
}

- (void)bind:(GLenum)side {
    glMaterialfv(side, GL_AMBIENT, (GLfloat *)&(self->_ambient));
    glMaterialfv(side, GL_DIFFUSE, (GLfloat *)&(self->_diffuse));
    glMaterialfv(side, GL_SPECULAR, (GLfloat *)&(self->_specular));
    glMaterialf(side, GL_SHININESS, self.shininess);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Ns: %.2f", self.name, self.shininess];
}

@end
