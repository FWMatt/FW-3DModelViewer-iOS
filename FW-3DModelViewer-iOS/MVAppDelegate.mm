//
//  MVAppDelegate.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVAppDelegate.h"

#import "MVGLModelViewController.h"
#import "MVModel.h"

#define TEST_FILEWRITE NO

@implementation MVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    NSString *storeFileName = @"3DModelViewer.sqlite";
    RKObjectManager *objectManager = [[RKObjectManager alloc] init];
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:storeFileName usingSeedDatabaseName:nil managedObjectModel:mom delegate:nil];
    
    [self seedDatabase];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[MVGLModelViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)seedDatabase {
    NSString *seededKey = @"MVStoreSeeded";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:seededKey])
        return;
    
    NSManagedObjectContext *context = [RKObjectManager sharedManager].objectStore.managedObjectContextForCurrentThread;
    NSString *modelDir = [[self documentsDirectory] stringByAppendingPathComponent:@"Models"];
    
    
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Soho Centro";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"009_soho_centro"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"Soho Centro.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Yasmin Solo";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"010_yasmin_solo"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"Yasmin Solo.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Yasmin Tranquillo";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"011_yasmin_tranquillo"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"Yasmin Tranquillo.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Chair";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"001_chair"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"chair.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Office Chair";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"002_office_chair"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"office_chair.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Pitcher";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"003_pitcher"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"pitcher.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Spaceship";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"004_ship"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"ship.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Sofa";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"005_sofa"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"sofa.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Knot";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"006_knot"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"knot.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Cube";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"007_cube"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"cube.obj"];
    }
    {
        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
        m.modelName = @"Sofa";
        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"008_sofa"];
        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"sofa_OBJ.obj"];
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
