#import <UIKit/UIKit.h>

@protocol AsyncCoordinatorResponder<NSObject>

- (void)responderOnStart;
- (void)responderOnComplete;

@end
