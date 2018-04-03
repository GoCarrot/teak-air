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
extern NSObject* TeakNotificationSchedule(const char* creativeId, const char* message, int64_t delay);
extern NSObject* TeakNotificationCancel(const char* scheduleId);
extern NSObject* TeakNotificationCancelAll();
extern BOOL TeakNotificationIsCompleted(NSObject* notif);
extern const char* TeakNotificationGetTeakNotifId(NSObject* notif);
extern const char* TeakNotificationGetStatus(NSObject* notif);
extern void TeakSetNumericAttribute(const char* cstr_key, double value);
extern void TeakSetStringAttribute(const char* cstr_key, const char* cstr_value);
extern BOOL TeakOpenSettingsAppToThisAppsSettings();

typedef void (^TeakLinkBlock)(NSDictionary* _Nonnull parameters);
extern void TeakRegisterRoute(const char* route, const char* name, const char* description, TeakLinkBlock block);

// From Teak.m
extern NSString* const TeakNotificationAppLaunch;
extern NSString* const TeakOnReward;

extern NSDictionary* TeakWrapperSDK;
extern NSDictionary* TeakVersionDict;

__attribute__((constructor))
static void teak_init()
{
   TeakWrapperSDK = @{@"adobeAir" : TEAK_VERSION};

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

void waitOnNotifFuture(NSObject* future, const uint8_t* eventName, FREContext context)
{
   if(future != nil)
   {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
         while(!TeakNotificationIsCompleted(future))
         {
            sleep(1);
         }

         const char* notifId = TeakNotificationGetTeakNotifId(future);
         const char* status = TeakNotificationGetStatus(future);
         NSDictionary* data = @{
            @"status" : status == nil ? [NSNull null] : [NSString stringWithUTF8String:status],
            @"data" : notifId == nil ? [NSNull null] : [NSString stringWithUTF8String:notifId]
         };
         NSError* error = nil;
         NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];

         NSString* eventData = @"{\"status\":\"error.internal\"}";
         if(error == nil)
         {
            eventData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         }

         FREDispatchStatusEventAsync(context, eventName, (const uint8_t*)[eventData UTF8String]);
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
      NSObject* notif = TeakNotificationSchedule((const char*)creativeId, (const char*)message, (int64_t)delay);
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
      NSObject* notif = TeakNotificationCancel((const char*)notifId);
      waitOnNotifFuture(notif, (const uint8_t*)"NOTIFICATION_CANCELED", context);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(cancelAllNotifications)
{
   NSObject* notif = TeakNotificationCancelAll();
   waitOnNotifFuture(notif, (const uint8_t*)"NOTIFICATION_CANCEL_ALL", context);

   return nil;
}

DEFINE_ANE_FUNCTION(registerRoute)
{
   const uint8_t* eventCode = (const uint8_t*)"DEEP_LINK";

   uint32_t stringLength;
   const uint8_t* route;
   const uint8_t* name;
   const uint8_t* description;
   if(FREGetObjectAsUTF8(argv[0], &stringLength, &route) == FRE_OK &&
      FREGetObjectAsUTF8(argv[1], &stringLength, &name) == FRE_OK &&
      FREGetObjectAsUTF8(argv[2], &stringLength, &description) == FRE_OK)
   {
      NSString* nsRoute = [NSString stringWithUTF8String:(const char*)route];

      TeakRegisterRoute((const char*)route, (const char*)name, (const char*)description, ^(NSDictionary * _Nonnull parameters) {
         NSError* error = nil;
         NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"route":nsRoute, @"parameters" : parameters}
                                                            options:0
                                                              error:&error];

         if (error != nil) {
            NSLog(@"[Teak:Air] Error converting to JSON: %@", error);
         } else {
            NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            FREDispatchStatusEventAsync(context, eventCode, (const uint8_t*)[jsonString UTF8String]);
         }
      });
   }

   return nil;
}

DEFINE_ANE_FUNCTION(getVersion)
{
   NSData* jsonData = [NSJSONSerialization dataWithJSONObject:TeakVersionDict
                                                      options:0
                                                        error:nil];
   NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
   FREObject ret;
   FRENewObjectFromUTF8((uint32_t)[jsonString length], (const uint8_t*)[jsonString UTF8String], &ret);
   return ret;
}

DEFINE_ANE_FUNCTION(setNumericAttribute)
{
   uint32_t stringLength;
   const uint8_t* key;
   double value;
   if(FREGetObjectAsUTF8(argv[0], &stringLength, &key) == FRE_OK &&
      FREGetObjectAsDouble(argv[1], &value) == FRE_OK)
   {
      TeakSetNumericAttribute((const char*)key, value);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(setStringAttribute)
{
   uint32_t stringLength;
   const uint8_t* key;
   const uint8_t* value;
   if(FREGetObjectAsUTF8(argv[0], &stringLength, &key) == FRE_OK &&
      FREGetObjectAsUTF8(argv[1], &stringLength, &value) == FRE_OK)
   {
      TeakSetStringAttribute((const char*)key, (const char*)value);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(openSettingsAppToThisAppsSettings)
{
   BOOL didOpenSettings = TeakOpenSettingsAppToThisAppsSettings();
   FREObject ret;
   FRENewObjectFromBool((uint32_t)didOpenSettings, &ret);
   return ret;
}

void checkTeakNotifLaunch(FREContext context, NSDictionary* userInfo)
{
   const uint8_t* eventCode = (const uint8_t*)"LAUNCHED_FROM_NOTIFICATION";
   const uint8_t* eventLevelEmpty = (const uint8_t*)"{}";

   NSError* error = nil;
   NSData* jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
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

void teakOnReward(FREContext context, NSDictionary* userInfo)
{
   const uint8_t* eventCode = (const uint8_t*)"ON_REWARD";
   const uint8_t* eventLevelEmpty = (const uint8_t*)"{}";

   NSError* error = nil;
   NSData* jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
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
   uint32_t numFunctions = 10;
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

   func[4].name = (const uint8_t*)"registerRoute";
   func[4].functionData = NULL;
   func[4].function = &registerRoute;

   func[5].name = (const uint8_t*)"getVersion";
   func[5].functionData = NULL;
   func[5].function = &getVersion;

   func[6].name = (const uint8_t*)"cancelAllNotifications";
   func[6].functionData = NULL;
   func[6].function = &cancelAllNotifications;

   func[7].name = (const uint8_t*)"setNumericAttribute";
   func[7].functionData = NULL;
   func[7].function = &setNumericAttribute;

   func[8].name = (const uint8_t*)"setStringAttribute";
   func[8].functionData = NULL;
   func[8].function = &setStringAttribute;

   func[8].name = (const uint8_t*)"openSettingsAppToThisAppsSettings";
   func[8].functionData = NULL;
   func[8].function = &openSettingsAppToThisAppsSettings;

   *functionsToSet = func;

   [[NSNotificationCenter defaultCenter] addObserverForName:TeakNotificationAppLaunch
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    checkTeakNotifLaunch(ctx, notification.userInfo);
                                                 }];
   [[NSNotificationCenter defaultCenter] addObserverForName:TeakOnReward
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    teakOnReward(ctx, notification.userInfo);
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
