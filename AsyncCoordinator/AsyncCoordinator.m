//
// Created by Nick Enchev on 2017-08-02.
// Copyright (c) 2017 Rover Parking Inc. All rights reserved.
//

#import "AsyncCoordinator.h"
#import "AsyncCoordinatorResult.h"

@interface AsyncCoordinator()

@property (nonatomic, strong) NSArray<id<AsyncCoordinatorResponder>> *responders;
@property (nonatomic, strong) NSMutableArray<AsyncCoordinatedTask *> *tasks;
@property (nonatomic, strong) NSMutableArray<AsyncCoordinatedTask *> *errorTasks;
@property (nonatomic, copy) AsyncCoordinatorCompletion completion;
@property (atomic, assign) BOOL used;
@property (atomic, assign) int taskIndex;
@property (nonatomic, assign) AsyncCoordinatorType coordinatorType;
@property (assign) int errorCount;
@property (assign) int numFinished;

@end

@implementation AsyncCoordinator


+ (AsyncCoordinator *)coordinator
{
	return [self coordinatorWithResponder:nil];
}

+ (AsyncCoordinator *)coordinatorWithResponder:(id <AsyncCoordinatorResponder>)responder
{
	return [AsyncCoordinator coordinatorWithResponder:responder andType:AsyncCoordinatorTypeParallel];
}

+ (AsyncCoordinator *)coordinatorWithResponder:(id<AsyncCoordinatorResponder>)responder andType:(AsyncCoordinatorType)type
{
	NSArray *responders = (responder != nil) ? @[responder] : [[NSArray alloc] init];
	return [AsyncCoordinator coordinatorWithResponders:responders andType:type];
}

+ (AsyncCoordinator *)coordinatorWithResponders:(NSArray<id<AsyncCoordinatorResponder>> *)responders andType:(AsyncCoordinatorType)type
{
	AsyncCoordinator *coordinator = [[AsyncCoordinator alloc] initWithResponders:responders andType:type];
	return coordinator;
}

+ (NSMutableArray *)coordinators
{
	static NSMutableArray *coordinators = nil;
	if (!coordinators)
	{
		coordinators = [[NSMutableArray alloc] init];
	}
	return coordinators;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.tasks = [[NSMutableArray alloc] init];
		self.errorTasks = [[NSMutableArray alloc] init];
		self.errorCount = 0;
		self.taskIndex = 0;
		self.numFinished = 0;
		self.continueOnError = NO;

		// keep the current coordinator in the static array, otherwise ARC destroys it
		// TODO: Find a better way to handle this
		[[AsyncCoordinator coordinators] addObject:self];
	}
	return self;
}

- (instancetype)initWithResponders:(NSArray<id<AsyncCoordinatorResponder>> *)responders
						   andType:(AsyncCoordinatorType)type
{
	self = [self init];
	if (self)
	{
		self.coordinatorType = type;
		self.responders = responders;
	}
	return self;
}

- (instancetype)initWithResponders:(NSArray<id<AsyncCoordinatorResponder>> *)responders
{
	return [self initWithResponders:responders andType:AsyncCoordinatorTypeParallel];
}

- (AsyncCoordinator *)coordinate:(AsyncCoordinatedBlock)block
{
	[self coordinateTask:[self newTaskWithBlock:block]];
	return self;
}

- (AsyncCoordinator *)coordinateTask:(AsyncCoordinatedTask *)task
{
	[self.tasks addObject:task];
	[task prepare:self];
	return self;
}

- (AsyncCoordinatedTask *)newTaskWithBlock:(AsyncCoordinatedBlock)block
{
	return [[AsyncCoordinatedTask alloc] initWithBlock:block];
}

- (void)taskFinished:(AsyncCoordinatedTask *)task
{
	@synchronized (task)
	{
		self.numFinished++;
		if (task.status == AsyncTaskStatusError)
		{
			[self.errorTasks addObject:task];
			self.errorCount++;
		}

		const BOOL allDone = self.numFinished >= [self.tasks count];
		if (allDone)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				for (id<AsyncCoordinatorResponder> responder in self.responders)
				{
					if ([responder respondsToSelector:@selector(responderOnComplete)]) [responder responderOnComplete];
				}
				if (self.completion) self.completion(self);
			});
		}
		else if (self.coordinatorType == AsyncCoordinatorTypeSerial)
		{
			[self coordinateSerial];
		}
	}
	if (task.completion && task.status == AsyncTaskStatusSuccess) task.completion();
}

- (void)performWithStart:(AsyncCoordinatorStart)start andCompletion:(AsyncCoordinatorCompletion)completion
{
	if ([self.tasks count])
	{
		self.used = YES;
		self.completion = completion;

		// start block and notify all responders
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (start) start();

			for (id<AsyncCoordinatorResponder> responder in self.responders)
			{
				if ([responder respondsToSelector:@selector(responderOnStart)]) [responder responderOnStart];
			}
		});

		if (self.coordinatorType == AsyncCoordinatorTypeParallel)
		{
			for (AsyncCoordinatedTask *task in self.tasks)
			{
				[task run];
			}
		}
		else if (self.coordinatorType == AsyncCoordinatorTypeSerial)
		{
			[self coordinateSerial];
		}
	}
}
- (void)coordinateSerial
{
	AsyncCoordinatedTask *prevTask = self.taskIndex > 0 ? [self.tasks objectAtIndex:self.taskIndex - 1] : nil;
	AsyncCoordinatedTask *task = [self.tasks objectAtIndex:self.taskIndex++];
	if (task)
	{
		task.previousTask = prevTask;
		if (prevTask == nil || prevTask.status == AsyncTaskStatusSuccess || prevTask.status == AsyncTaskStatusSkipped || self.continueOnError)
		{
			[task run];
		}
		else
		{
			[task skip];
		}
	}
}

- (BOOL)hasErrors
{
    return self.errorCount;
}

- (AsyncCoordinatedTask *)firstTask
{
	return [self.tasks firstObject];
}

- (AsyncCoordinatedTask *)lastTask
{
	return [self.tasks lastObject];
}

- (NSError *)firstError
{
	return [self.errorTasks firstObject].taskError;
}

@end
