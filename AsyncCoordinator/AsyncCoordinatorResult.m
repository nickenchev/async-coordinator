//
// Created by Nick Enchev on 2017-08-02.
// Copyright (c) 2017 Rover Parking Inc. All rights reserved.
//

#import "AsyncCoordinatorResult.h"

@interface AsyncCoordinatorResult()

@property (nonatomic, assign) BOOL isSuccess;

@end

@implementation AsyncCoordinatorResult

- (instancetype)initWithSuccess:(BOOL)success
{
	self = [super init];
	if (self)
	{
		self.isSuccess = success;
	}
	return self;
}

+ (AsyncCoordinatorResult *)success
{
	return [[AsyncCoordinatorResult alloc] initWithSuccess:YES];
}

+ (AsyncCoordinatorResult *)failure
{
	return [[AsyncCoordinatorResult alloc] initWithSuccess:NO];
}

@end