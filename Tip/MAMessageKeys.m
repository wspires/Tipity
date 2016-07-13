//
//  MAWatchKitExtensionKeys.m
//  Gym Log
//
//  Created by Wade Spires on 2/19/15.
//
//

#import "MAMessageKeys.h"

@implementation MAMessageKeys

+ (NSMutableDictionary *)dictForMsgType:(NSString *)msgType
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:msgType forKey:[MAMessageKeys msgType]];
    return dict;
}

+ (NSMutableDictionary *)dictForErrorMsg:(NSString *)errorMsg
{
    NSMutableDictionary *dict = [MAMessageKeys dictForMsgType:[MAMessageKeys errorMsgReply]];
    [dict setObject:errorMsg forKey:[MAMessageKeys errorMsgReply]];
    return dict;
}

+ (NSString *)msgType
{
    return @"msgType";
}

+ (NSString *)transferLoggedWorkoutSet
{
    return @"transferLoggedWorkoutSet";
}

+ (NSString *)requestAllSharedData
{
    return @"requestAllSharedData";
}
+ (NSString *)allSharedDataReply
{
    return @"allSharedDataReply";
}
+ (NSString *)requestUserUtil
{
    return @"requestUserUtil";
}
+ (NSString *)userUtilReply
{
    return @"userUtilReply";
}
+ (NSString *)requestRoutineList
{
    return @"requestRoutineList";
}
+ (NSString *)routineListReply
{
    return @"routineListReply";
}
+ (NSString *)requestWorkoutSessions
{
    return @"requestWorkoutSessions";
}
+ (NSString *)workoutSessionsReply
{
    return @"workoutSessionsReply";
}
+ (NSString *)requestCurrentWorkoutSession
{
    return @"requestCurrentWorkoutSession";
}
+ (NSString *)currentWorkoutSessionReply
{
    return @"currentWorkoutSessionReply";
}
+ (NSString *)requestExercises
{
    return @"requestExercises";
}
+ (NSString *)exercisesReply
{
    return @"exercisesReply";
}
+ (NSString *)requestCardioExercises
{
    return @"requestCardioExercises";
}
+ (NSString *)cardioExercisesReply
{
    return @"cardioExercisesReply";
}

+ (NSString *)requestWorkoutSession
{
    return @"requestWorkoutSession";
}
+ (NSString *)workoutSessionReply
{
    return @"workoutSessionReply";
}

+ (NSString *)requestWorkoutSets
{
    return @"requestWorkoutSets";
}
+ (NSString *)workoutSetsReply
{
    return @"workoutSetsReply";
}

+ (NSString *)startRestTimerRequest
{
    return @"startRestTimerRequest";
}
+ (NSString *)stopRestTimerRequest
{
    return @"stopRestTimerRequest";
}

+ (NSString *)startWorkoutMessage
{
    return @"startWorkout";
}
+ (NSString *)finishWorkoutMessage
{
    return @"finishWorkout";
}

+ (NSString *)updateWorkoutSessionDateRequest
{
    return @"updateWorkoutSessionDate";
}

+ (NSString *)checkForFirstRunRequest
{
    return @"checkForFirstRunRequest";
}
+ (NSString *)checkForFirstRunReply
{
    return @"checkForFirstRunReply";
}

+ (NSString *)transferDiscardedWorkout
{
    return @"transferDiscardedWorkout";
}

+ (NSString *)errorMsgReply
{
    return @"errorMsg";
}
+ (NSString *)upgradeMsgReply
{
    return @"upgradeMsg";
}

+ (NSString *)workoutSet
{
    return @"workoutSet";
}

+ (NSString *)sendTime
{
    return @"sendTime";
}
+ (NSString *)replyTime
{
    return @"replyTime";
}

@end
