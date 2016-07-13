//
//  MAWatchKitExtensionKeys.h
//  Gym Log
//
//  Created by Wade Spires on 2/19/15.
//
//

#import <Foundation/Foundation.h>

// Message keys for message dictionaries sent between the iPhone and Apple Watch.
@interface MAMessageKeys : NSObject

// Construct a dictionary for sending with the given request type.
+ (NSMutableDictionary *)dictForMsgType:(NSString *)msgType;
+ (NSMutableDictionary *)dictForErrorMsg:(NSString *)errorMsg;

+ (NSString *)msgType;

+ (NSString *)transferLoggedWorkoutSet;

+ (NSString *)requestAllSharedData;
+ (NSString *)allSharedDataReply;

+ (NSString *)requestUserUtil;
+ (NSString *)userUtilReply;

+ (NSString *)requestRoutineList;
+ (NSString *)routineListReply;

+ (NSString *)requestWorkoutSessions;
+ (NSString *)workoutSessionsReply;

+ (NSString *)requestCurrentWorkoutSession;
+ (NSString *)currentWorkoutSessionReply;

+ (NSString *)requestExercises;
+ (NSString *)exercisesReply;

+ (NSString *)requestCardioExercises;
+ (NSString *)cardioExercisesReply;

+ (NSString *)requestWorkoutSession;
+ (NSString *)workoutSessionReply;

+ (NSString *)requestWorkoutSets;
+ (NSString *)workoutSetsReply;

+ (NSString *)startRestTimerRequest;
+ (NSString *)stopRestTimerRequest;

+ (NSString *)startWorkoutMessage;
+ (NSString *)finishWorkoutMessage;

+ (NSString *)updateWorkoutSessionDateRequest;
+ (NSString *)checkForFirstRunRequest;
+ (NSString *)checkForFirstRunReply;

+ (NSString *)transferDiscardedWorkout;

+ (NSString *)errorMsgReply;
+ (NSString *)upgradeMsgReply;

+ (NSString *)workoutSet;

// Keys to replyInfo responses returned back to the watch.
+ (NSString *)sendTime;
+ (NSString *)replyTime;

@end
