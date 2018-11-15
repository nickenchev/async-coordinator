//
// Created by Nick Enchev on 2017-08-02.
// Copyright (c) 2017 Rover Parking Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncCoordinatorResponder.h"
#import "AsyncCoordinatedTask.h"

//! Project version number for AsyncCoordinator.
FOUNDATION_EXPORT double AsyncCoordinatorVersionNumber;

//! Project version string for AsyncCoordinator.
FOUNDATION_EXPORT const unsigned char AsyncCoordinatorVersionString[];

@class AsyncCoordinator;
@class AsyncCoordinatorResult;

typedef void (^AsyncCoordinatorStart)(void);
typedef void (^AsyncCoordinatorCompletion)(AsyncCoordinator *coordinator);

typedef enum AsyncCoordinatorType : NSUInteger
{
	AsyncCoordinatorTypeParallel,
	AsyncCoordinatorTypeSerial
} AsyncCoordinatorType;

@interface AsyncCoordinator : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<AsyncCoordinatedTask *> *tasks;
@property (nonatomic, strong, readonly) NSMutableArray<AsyncCoordinatedTask *> *errorTasks;
@property (nonatomic, assign, readonly) int errorCount;
@property (assign) BOOL continueOnError;

+ (AsyncCoordinator *)coordinator;
+ (AsyncCoordinator *)coordinatorWithResponder:(id<AsyncCoordinatorResponder>)responder;
+ (AsyncCoordinator *)coordinatorWithResponder:(id<AsyncCoordinatorResponder>)responder andType:(AsyncCoordinatorType)type;
+ (AsyncCoordinator *)coordinatorWithResponders:(NSArray<id<AsyncCoordinatorResponder>> *)responders andType:(AsyncCoordinatorType)type;

- (instancetype)initWithResponders:(NSArray<id<AsyncCoordinatorResponder>> *)responders
						   andType:(AsyncCoordinatorType)type;
- (instancetype)initWithResponders:(NSArray<id<AsyncCoordinatorResponder>> *)responders;
- (AsyncCoordinator *)coordinate:(AsyncCoordinatedBlock)block;
- (AsyncCoordinator *)coordinateTask:(AsyncCoordinatedTask *)task;
- (AsyncCoordinatedTask *)newTaskWithBlock:(AsyncCoordinatedBlock)block;
- (void)taskFinished:(AsyncCoordinatedTask *)task;
- (void)performWithStart:(AsyncCoordinatorStart)start andCompletion:(AsyncCoordinatorCompletion)completion;
- (BOOL)hasErrors;
- (AsyncCoordinatedTask *)firstTask;
- (AsyncCoordinatedTask *)lastTask;
- (NSError *)firstError;

@end
