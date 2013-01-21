//
//  MVAppDelegate.h
//  3D Model Viewer
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

@class MVRootViewController;

@interface MVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MVRootViewController *viewController;
@property (nonatomic, strong) RKManagedObjectStore *store;

@end
