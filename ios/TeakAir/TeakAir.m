/* Teak -- Copyright (C) 2016 GoCarrot Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

// From TeakHooks.m
extern void Teak_Plant(Class appDelegateClass, NSString* appId, NSString* appSecret);

// From TeakCExtern.m
extern void TeakIdentifyUser(const char* userId);
extern void* TeakRewardRewardForId(NSString* teakRewardId);
extern BOOL TeakRewardIsCompleted(void* notif);
extern const char* TeakRewardGetJson(void* reward);
extern void* TeakNotificationSchedule(const char* creativeId, const char* message, uint64_t delay);
extern void* TeakNotificationCancel(const char* scheduleId);
extern BOOL TeakNotificationIsCompleted(void* notif);
extern const char* TeakNotificationGetTeakNotifId(void* notif);

// From Teak.m
extern NSString* const TeakNotificationAppLaunch;

__attribute__((constructor))
static void teak_init()
{
   NSString* appId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TeakAppId"];
   NSString* apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TeakApiKey"];
   Teak_Plant(NSClassFromString(@"CTAppController"), appId, apiKey);
}

DEFINE_ANE_FUNCTION(identifyUser)
{
   uint32_t stringLength;
   const uint8_t* userId;
   if(FREGetObjectAsUTF8(argv[0], &stringLength, &userId) == FRE_OK)
   {
      TeakIdentifyUser((const char*)userId);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(_log)
{
   uint32_t stringLength;
   const uint8_t* userId;
   if(FREGetObjectAsUTF8(argv[0], &stringLength, &userId) == FRE_OK)
   {
      NSLog(@"[Teak:Air] %s", (const char*)userId);
   }

   return nil;
}

void waitOnNotifFuture(void* future, const uint8_t* eventName, FREContext context)
{
   if(future != nil)
   {
      __block NSObject* o = (__bridge NSObject*)(future);
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
         while(!TeakNotificationIsCompleted(future))
         {
            sleep(1);
         }
         const uint8_t* notifId = (const uint8_t*)TeakNotificationGetTeakNotifId(future);
         FREDispatchStatusEventAsync(context, eventName, notifId);
      });
   }
}

DEFINE_ANE_FUNCTION(scheduleNotification)
{
   uint32_t stringLength;
   const uint8_t* creativeId;
   const uint8_t* message;
   double delay;
   if(FREGetObjectAsUTF8(argv[0], &stringLength, &creativeId) == FRE_OK &&
      FREGetObjectAsUTF8(argv[1], &stringLength, &message) == FRE_OK &&
      FREGetObjectAsDouble(argv[2], &delay) == FRE_OK)
   {
      void* notif = TeakNotificationSchedule((const char*)creativeId, (const char*)message, (uint64_t)delay);
      waitOnNotifFuture(notif, (const uint8_t*)"NOTIFICATION_SCHEDULED", context);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(cancelNotification)
{
   uint32_t stringLength;
   const uint8_t* notifId;
   if(FREGetObjectAsUTF8(argv[0], &stringLength, &notifId) == FRE_OK)
   {
      void* notif = TeakNotificationCancel((const char*)notifId);
      waitOnNotifFuture(notif, (const uint8_t*)"NOTIFICATION_CANCELED", context);
   }

   return nil;
}

void checkTeakNotifLaunch(FREContext context, NSDictionary* userInfo)
{
   const uint8_t* eventCode = (const uint8_t*)"LAUNCHED_FROM_NOTIFICATION";
   const uint8_t* eventLevelEmpty = (const uint8_t*)"{}";

   NSMutableDictionary* eventDataDictionary = [NSMutableDictionary dictionary];

   NSDictionary* teakReward = [userInfo objectForKey:@"teakReward"];
   if(teakReward != nil)
   {
      [eventDataDictionary setObject:teakReward forKey:@"reward"];
   }

   NSURL* teakDeepLink = [userInfo objectForKey:@"teakDeepLink"];
   if(teakDeepLink != nil)
   {
      [eventDataDictionary setObject:[teakDeepLink absoluteString] forKey:@"deepLink"];
   }

   NSError* error = nil;
   NSData* jsonData = [NSJSONSerialization dataWithJSONObject:eventDataDictionary
                                                      options:0
                                                        error:&error];

   if (error != nil) {
      NSLog(@"[Teak:Air] Error converting to JSON: %@", error);
      FREDispatchStatusEventAsync(context, eventCode, eventLevelEmpty);
   } else {
      NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      FREDispatchStatusEventAsync(context, eventCode, (const uint8_t*)[jsonString UTF8String]);
   }
}

void AirTeakContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
   uint32_t numFunctions = 4;
   *numFunctionsToTest = numFunctions;
   FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * numFunctions);

   func[0].name = (const uint8_t*)"identifyUser";
   func[0].functionData = NULL;
   func[0].function = &identifyUser;

   func[1].name = (const uint8_t*)"_log";
   func[1].functionData = NULL;
   func[1].function = &_log;

   func[2].name = (const uint8_t*)"scheduleNotification";
   func[2].functionData = NULL;
   func[2].function = &scheduleNotification;

   func[3].name = (const uint8_t*)"cancelNotification";
   func[3].functionData = NULL;
   func[3].function = &cancelNotification;

   *functionsToSet = func;

   [[NSNotificationCenter defaultCenter] addObserverForName:TeakNotificationAppLaunch
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    checkTeakNotifLaunch(ctx, notification.userInfo);
                                                 }];
}

void AirTeakContextFinalizer(FREContext ctx) {}

void AirTeakFinalizer(void* extData) {}

void AirTeakInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
   *extDataToSet = NULL;
   *ctxInitializerToSet = &AirTeakContextInitializer;
   *ctxFinalizerToSet = &AirTeakContextFinalizer;
}
