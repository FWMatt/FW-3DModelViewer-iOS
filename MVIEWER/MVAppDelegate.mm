//
//  MVAppDelegate.m
//  3D Model Viewer
//
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVAppDelegate.h"

#import "MVRootViewController.h"
#import "MVModel.h"

#define TEST_FILEWRITE NO

@implementation MVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *storeFileName = @"MVIEWER.sqlite";
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:storeFileName];
    
    [self seedDatabase];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[MVRootViewController alloc] init];
    self.window.rootViewController = self.viewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)seedDatabase {
    NSString *seededKey = @"MVStoreSeeded";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:seededKey] boolValue])
        return;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSString *modelDir = [[self documentsDirectory] stringByAppendingPathComponent:@"Models"];
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Chair";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"001_chair"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"chair.obj"];
        m.index = 0;
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Office Chair";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"002_office_chair"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"office_chair.obj"];
        m.index = 1;
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Pitcher";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"003_pitcher"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"pitcher.obj"];
        m.index = 2;
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Spaceship";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"004_ship"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"ship.obj"];
        m.index = 3;
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Sofa";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"005_sofa"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"sofa.obj"];
        m.index = 4;
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Knot";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"006_knot"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"knot.obj"];
        m.index = 5;
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Sofa";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"007_sofa"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"sofa_OBJ.obj"];
        m.index = 6;
    }
    
    [context save:NULL];
    [defaults setBool:YES forKey:seededKey];
    [defaults synchronize];    
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

@end
