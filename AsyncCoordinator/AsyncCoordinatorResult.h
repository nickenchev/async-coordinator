//
// Created by Nick Enchev on 2017-08-02.
// Copyright (c) 2017 Rover Parking Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncCoordinatorResult : NSObject

@property (nonatomic, assign, readonly) BOOL isSuccess;

+ (AsyncCoordinatorResult *)success;
+ (AsyncCoordinatorResult *)failure;

@end
