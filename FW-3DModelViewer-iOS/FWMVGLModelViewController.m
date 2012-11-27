//
//  FWMVGLModelViewController.m
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 26/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "FWMVGLModelViewController.h"
#import "FWMVGLModelView.h"
#import "GLModel.h"
#import "GLLight.h"
#import "GLImage.h"
#import "FWMVGLModelView.h"
@interface FWMVGLModelViewController ()

@property (nonatomic,retain) FWMVGLModelView *modelView;

@end

@interface GLModelView (asdf)

@property (nonatomic, assign) CATransform3D transform;

@end

@implementation FWMVGLModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.modelView = [[FWMVGLModelView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.modelView];
    [self setModel];
}

- (void)setModel
{
    //set model
    self.modelView.texture = nil;
    self.modelView.blendColor = [UIColor whiteColor];
    self.modelView.model = [GLModel modelWithContentsOfFile:@"translated_desk.obj"];
    
    GLLight *light = [[GLLight alloc] init];
    light.ambientColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f];
    light.specularColor = [UIColor colorWithRed:0.3f green:1.0f blue:0.3f alpha:1.0f];
    light.diffuseColor = [UIColor colorWithRed:0.2f green:0.5f blue:0.2f alpha:1.0f];
    
    light.transform = CATransform3DMakeTranslation(0.0f, 2.0f, 0.0f);
    
    self.modelView.lights = @[light];
    //set default transform
    //self.modelView.transform = CATransform3DMakeScale(0.01f, 0.01f, 0.01f);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.modelView startAnimating];
}
@end
