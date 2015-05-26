//
//  FISAppDelegate.m
//  ios-variable-scope
//
//  Created by iOS Staff on 5/12/15
//  Copyright (c) 2015 The Flatiron School. All rights reserved.
//

#import "FISAppDelegate.h"

@interface FISAppDelegate ()

@end


@implementation FISAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (NSMutableArray *)arrayByAddingString:(NSString *)string toArray:(NSMutableArray *)array
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:array];
    [newArray addObject:string];
    return newArray;
}

- (NSUInteger)countOfStringsInAllCapsInArray:(NSArray *)array;
{
    NSUInteger count = 0;
    for (NSString *word in array){
        if ([word isEqualToString:[word uppercaseString]]){
            count += 1;
        }
    }
    return count;
}

- (void)removeAllElementsFromArray:(NSMutableArray *)array
{
    [array removeAllObjects];
}

// Pull object from index: i and assign to variable {}
// NSString *wordTester = [array objectAtIndex:i];

// Remove all accents and reassign to new variable
// NSString* wordTested = [[wordTester componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];

// Add new updated objects to new array for counter
// Add +1 to counter for each after same test from above


@end
