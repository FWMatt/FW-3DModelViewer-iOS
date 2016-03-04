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
//    if ([[defaults valueForKey:seededKey] boolValue])
//        return;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSString *modelDir = [[self documentsDirectory] stringByAppendingPathComponent:@"Models"];
    [MVModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES]];
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


// Some more furniture goes here
    
//    {
//        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
//        m.modelName = @"Stand";
//        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"008_stand"];
//        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"1.obj"];
//        m.index = 0;
//    }
//    {
//        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
//        m.modelName = @"Stand";
//        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"9"];
//        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"HSM0018.obj"];
//        m.index = 0;
//    }
//    {
//        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
//        m.modelName = @"Stand";
//        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"10"];
//        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"10259_Wingback_Chair_v2_max2011_it1_v4.obj"];
//        m.index = 0;
//    }
//    {
//        MVModel *m = [NSEntityDescription insertNewObjectForEntityForName:@"MVModel" inManagedObjectContext:context];
//        m.modelName = @"Stand";
//        m.modelDirectory = [modelDir stringByAppendingPathComponent:@"11"];
//        m.objPath = [m.modelDirectory stringByAppendingPathComponent:@"5354967.obj"];
//        m.index = 0;
//    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [defaults setBool:YES forKey:seededKey];
    [defaults synchronize];    
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

@end
