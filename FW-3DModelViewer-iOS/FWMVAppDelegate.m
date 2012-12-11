//
//  FWMVAppDelegate.m
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "FWMVAppDelegate.h"

#import "FWMVGLModelViewController.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"

#define TEST_FILEWRITE NO

@implementation FWMVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *modelsPath = [documentsDirectory stringByAppendingPathComponent:@"Models"];
    if (TEST_FILEWRITE) {
        NSError *error = nil;
        [fileManager removeItemAtPath:modelsPath error:&error];
        NSLog(@"%@",error);
    }
    
    if (![fileManager fileExistsAtPath:modelsPath isDirectory:nil]) {
        [fileManager createDirectoryAtPath:modelsPath withIntermediateDirectories:NO attributes:nil error:nil];
        NSInteger i = 0;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setMinimumIntegerDigits:3];

        ZipFile *zipFile = [[ZipFile alloc] initWithFileName:[[NSBundle mainBundle] pathForResource:@"model_examples" ofType:@"zip"] mode:ZipFileModeUnzip];
        
        for (FileInZipInfo *zipContent in [zipFile listFileInZipInfos]) {
            NSString *firstChar = [zipContent.name substringToIndex:1];
            if (!firstChar || [firstChar isEqualToString:@"."] || [firstChar isEqualToString:@"_"]) {
                continue;
            }
            NSError *error = nil;
            NSNumber *fileNum = @(i);
            [zipFile locateFileInZip:zipContent.name];
            ZipReadStream *read1= [zipFile readCurrentFileInZip];

            NSMutableData *modelData = [[NSMutableData alloc] initWithLength:zipContent.length];
            [read1 readDataWithBuffer:modelData];
            
            [modelData writeToFile:[modelsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[formatter stringFromNumber:fileNum],zipContent.name]]  options:0 error:&error];
            NSLog(@"%@",error);
            i++;
        }
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[FWMVGLModelViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
