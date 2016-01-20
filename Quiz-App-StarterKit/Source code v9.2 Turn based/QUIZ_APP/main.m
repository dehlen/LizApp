//
//  main.m
//  QUIZ_APP
//
//  Created by Satish Nerlekar on 31/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        int retval;
        @try{
            retval = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception)
        {
            NSLog(@"Gosh!!! %@", [exception callStackSymbols]);
            @throw;
        }
        return retval;
    }
}
