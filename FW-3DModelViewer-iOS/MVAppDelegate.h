//
//  MVAppDelegate.h
//  3D Model Viewer
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MVGLModelViewController;

@interface MVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MVGLModelViewController *viewController;

@end
