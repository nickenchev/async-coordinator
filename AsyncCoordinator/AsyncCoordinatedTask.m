//
// Created by Nikola Enchev on 2017-09-05.
// Copyright (c) 2017 Rover Parking Inc. All rights reserved.
//

#import "AsyncCoordinatedTask.h"
#import "AsyncCoordinator.h"

@interface AsyncCoordinatedTask()

@property (nonatomic, strong) AsyncCoordinator *coordinator;
@property (nonatomic, copy) AsyncCoordinatedBlock block;
@property (nonatomic, strong) id resultData;
@property (nonatomic, strong) NSError *taskError;

@end

@implementation AsyncCoordinatedTask

- (instancetype)initWithBlock:(AsyncCoordinatedBlock)block
{
	self = [super init];
	if (self)
	{
		self.block = block;
		self.status = AsyncTaskStatusWaiting;
	}
	return self;
}

- (void)setTaskResultData:(id)data
{
	self.resultData = data;
}

- (id)getTaskResultData
{
	return self.resultData;
}

- (void)prepare:(AsyncCoordinator *)coordinator
{
	self.coordinator = coordinator;
}

- (void)run
{
	if (self.conditionBlock && !self.conditionBlock())
	{
		[self skip];
	}
	else
	{
		self.status = AsyncTaskStatusRunning;
		if (self.preExecute) self.preExecute();
		if (self.block) self.block(self);
	}
}

- (void)success
{
	self.status = AsyncTaskStatusSuccess;
	if (self.taskDataBlock) self.taskDataBlock(self.resultData);
	[self.coordinator taskFinished:self];
}

- (void)error:(NSError *)taskError
{
	self.status = AsyncTaskStatusError;
	self.taskError = taskError;
	[self.coordinator taskFinished:self];
}

- (void)skip
{
	self.status = AsyncTaskStatusSkipped;
	[self.coordinator taskFinished:self];
}

@end
