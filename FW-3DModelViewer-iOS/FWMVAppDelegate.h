//
//  FWMVAppDelegate.h
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWMVViewController;

@interface FWMVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FWMVViewController *viewController;

@end
