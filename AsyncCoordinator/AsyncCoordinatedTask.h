//
// Created by Nikola Enchev on 2017-09-05.
// Copyright (c) 2017 Rover Parking Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AsyncCoordinator;
@class AsyncCoordinatedTask;

typedef NS_ENUM(NSUInteger, AsyncTaskStatus)
{
	AsyncTaskStatusWaiting,
	AsyncTaskStatusRunning,
	AsyncTaskStatusSuccess,
	AsyncTaskStatusSkipped,
	AsyncTaskStatusError
};

typedef void (^AsyncCoordinatedBlock)(AsyncCoordinatedTask *task);
typedef void (^TaskCompletion)(void);
typedef BOOL (^TaskCoordinateCondition)(void);
typedef void (^TaskPreExecute)(void);
typedef void (^TaskDataBlock)(id resultData);
typedef id (^TaskInputDataBlock)(void);

@interface AsyncCoordinatedTask : NSObject

@property (atomic, assign) AsyncTaskStatus status;
@property (nonatomic, copy) TaskCoordinateCondition conditionBlock;
@property (nonatomic, copy) TaskDataBlock taskDataBlock;
@property (nonatomic, copy) TaskInputDataBlock taskInputData;
@property (nonatomic, strong, readonly) NSError *taskError;
@property (nonatomic, weak) AsyncCoordinatedTask *previousTask;
@property (nonatomic, copy) TaskPreExecute preExecute;
@property (nonatomic, copy) TaskCompletion completion;

- (instancetype)initWithBlock:(AsyncCoordinatedBlock)block;
- (void)prepare:(AsyncCoordinator *)coordinator;
- (void)run;
- (void)success;
- (void)error:(NSError *)error;
- (void)skip;
- (void)setTaskResultData:(id)data;
- (id)getTaskResultData;

@end
