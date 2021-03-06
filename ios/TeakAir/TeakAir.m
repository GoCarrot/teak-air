#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

// From TeakHooks.m
extern void Teak_Plant(Class appDelegateClass, NSString* appId, NSString* appSecret);

// From TeakCExtern.m
extern void TeakIdentifyUser(const char* userId, const char* optOutJsonArray, const char* email);
extern NSObject* TeakNotificationSchedule(const char* creativeId, const char* message, int64_t delay);
extern NSObject* TeakNotificationScheduleLongDistanceWithNSArray(const char* creativeId, int64_t delay, NSArray* userIds);
extern NSObject* TeakNotificationCancel(const char* scheduleId);
extern NSObject* TeakNotificationCancelAll();
extern BOOL TeakNotificationIsCompleted(NSObject* notif);
extern const char* TeakNotificationGetTeakNotifId(NSObject* notif);
extern const char* TeakNotificationGetStatus(NSObject* notif);
extern void TeakSetNumericAttribute(const char* cstr_key, double value);
extern void TeakSetStringAttribute(const char* cstr_key, const char* cstr_value);
extern void TeakTrackEvent(const char* cstr_actionId, const char* cstr_objectTypeId, const char* cstr_objectInstanceId);
extern void TeakIncrementEvent(const char* cstr_actionId, const char* cstr_objectTypeId, const char* cstr_objectInstanceId, int64_t count);
extern BOOL TeakOpenSettingsAppToThisAppsSettings();
extern int TeakGetNotificationState();
extern const char* TeakGetAppConfiguration();
extern const char* TeakGetDeviceConfiguration();
extern void TeakReportTestException();
extern BOOL TeakRequestProvisionalPushAuthorization();
extern void TeakProcessDeepLinks();

typedef void (^TeakLinkBlock)(NSDictionary* _Nonnull parameters);
extern void TeakRegisterRoute(const char* route, const char* name, const char* description, TeakLinkBlock block);

// From Teak.m
extern NSString* const TeakNotificationAppLaunch;
extern NSString* const TeakOnReward;
extern NSString* const TeakForegroundNotification;
extern NSString* const TeakAdditionalData;

extern NSDictionary* TeakWrapperSDK;
extern NSDictionary* TeakVersionDict;

typedef void (^TeakLogListener)(NSString* _Nonnull event,
                                NSString* _Nonnull level,
                                NSDictionary* _Nullable eventData);

extern void TeakSetLogListener(TeakLogListener listener);

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
   const uint8_t* userId = NULL;
   const uint8_t* optOutJson = NULL;
   const uint8_t* email = NULL;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &userId) == FRE_OK) &&
      (argv[1] == NULL || FREGetObjectAsUTF8(argv[1], &stringLength, &optOutJson) == FRE_OK) &&
      (argv[2] == NULL || FREGetObjectAsUTF8(argv[2], &stringLength, &email) == FRE_OK))
   {
      TeakIdentifyUser((const char*)userId, (const char*)optOutJson, (const char*)email);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(_log)
{
   uint32_t stringLength;
   const uint8_t* userId = NULL;
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
   const uint8_t* creativeId = NULL;
   const uint8_t* message = NULL;
   double delay;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &creativeId) == FRE_OK) &&
      (argv[1] == NULL || FREGetObjectAsUTF8(argv[1], &stringLength, &message) == FRE_OK) &&
      FREGetObjectAsDouble(argv[2], &delay) == FRE_OK)
   {
      NSObject* notif = TeakNotificationSchedule((const char*)creativeId, (const char*)message, (int64_t)delay);
      waitOnNotifFuture(notif, (const uint8_t*)"NOTIFICATION_SCHEDULED", context);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(scheduleLongDistanceNotification)
{
   uint32_t stringLength, arrayLength;
   const uint8_t* creativeId = NULL;
   double delay;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &creativeId) == FRE_OK) &&
      FREGetObjectAsDouble(argv[1], &delay) == FRE_OK &&
      FREGetArrayLength(argv[2], &arrayLength) == FRE_OK)
   {
      NSMutableArray* userIds = [[NSMutableArray alloc] init];
      for (uint32_t i = 0; i < arrayLength; i++)
      {
         FREObject elem;
         const uint8_t* elemAsStr;
         if (FREGetArrayElementAt(argv[2], i, &elem) == FRE_OK &&
             FREGetObjectAsUTF8(elem, &stringLength, &elemAsStr) == FRE_OK)
         {
            [userIds addObject:[NSString stringWithUTF8String:(const char*)elemAsStr]];
         }
      }
      NSObject* notif = TeakNotificationScheduleLongDistanceWithNSArray((const char*)creativeId, (int64_t)delay, userIds);
      waitOnNotifFuture(notif, (const uint8_t*)"LONG_DISTANCE_NOTIFICATION_SCHEDULED", context);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(cancelNotification)
{
   uint32_t stringLength;
   const uint8_t* notifId = NULL;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &notifId) == FRE_OK))
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
   const uint8_t* route = NULL;
   const uint8_t* name = NULL;
   const uint8_t* description = NULL;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &route) == FRE_OK) &&
      (argv[1] == NULL || FREGetObjectAsUTF8(argv[1], &stringLength, &name) == FRE_OK) &&
      (argv[2] == NULL || FREGetObjectAsUTF8(argv[2], &stringLength, &description) == FRE_OK))
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
   const uint8_t* key = NULL;
   double value;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &key) == FRE_OK) &&
      FREGetObjectAsDouble(argv[1], &value) == FRE_OK)
   {
      TeakSetNumericAttribute((const char*)key, value);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(setStringAttribute)
{
   uint32_t stringLength;
   const uint8_t* key = NULL;
   const uint8_t* value = NULL;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &key) == FRE_OK) &&
      (argv[1] == NULL || FREGetObjectAsUTF8(argv[1], &stringLength, &value) == FRE_OK))
   {
      TeakSetStringAttribute((const char*)key, (const char*)value);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(trackEvent)
{
   uint32_t stringLength;
   const uint8_t* actionId = NULL;
   const uint8_t* objectTypeId = NULL;
   const uint8_t* objectInstanceId = NULL;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &actionId) == FRE_OK) &&
      (argv[1] == NULL || FREGetObjectAsUTF8(argv[1], &stringLength, &objectTypeId) == FRE_OK) &&
      (argv[2] == NULL || FREGetObjectAsUTF8(argv[2], &stringLength, &objectInstanceId) == FRE_OK))
   {
      TeakTrackEvent((const char*)actionId, (const char*)objectTypeId, (const char*)objectInstanceId);
   }

   return nil;
}

DEFINE_ANE_FUNCTION(incrementEvent)
{
   uint32_t stringLength;
   double count;
   const uint8_t* actionId = NULL;
   const uint8_t* objectTypeId = NULL;
   const uint8_t* objectInstanceId = NULL;
   if((argv[0] == NULL || FREGetObjectAsUTF8(argv[0], &stringLength, &actionId) == FRE_OK) &&
      (argv[1] == NULL || FREGetObjectAsUTF8(argv[1], &stringLength, &objectTypeId) == FRE_OK) &&
      (argv[2] == NULL || FREGetObjectAsUTF8(argv[2], &stringLength, &objectInstanceId) == FRE_OK) &&
      FREGetObjectAsDouble(argv[3], &count) == FRE_OK)
   {
      TeakIncrementEvent((const char*)actionId, (const char*)objectTypeId, (const char*)objectInstanceId, (int64_t)count);
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

DEFINE_ANE_FUNCTION(getNotificationState)
{
   FREObject ret;
   FRENewObjectFromInt32((int32_t) TeakGetNotificationState(), &ret);
   return ret;
}

DEFINE_ANE_FUNCTION(getAppConfiguration)
{
   NSData* data = [[NSString stringWithUTF8String:TeakGetAppConfiguration()] dataUsingEncoding:NSUTF8StringEncoding];
   NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   FREObject ret;
   FRENewObjectFromUTF8((uint32_t)[jsonString length], (const uint8_t*)[jsonString UTF8String], &ret);
   return ret;
}

DEFINE_ANE_FUNCTION(getDeviceConfiguration)
{
   NSData* data = [[NSString stringWithUTF8String:TeakGetDeviceConfiguration()] dataUsingEncoding:NSUTF8StringEncoding];
   NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   FREObject ret;
   FRENewObjectFromUTF8((uint32_t)[jsonString length], (const uint8_t*)[jsonString UTF8String], &ret);
   return ret;
}

DEFINE_ANE_FUNCTION(reportTestException)
{
   TeakReportTestException();
   return nil;
}

DEFINE_ANE_FUNCTION(requestProvisionalPushAuthorization)
{
   BOOL didRequestProvisional = TeakRequestProvisionalPushAuthorization();
   FREObject ret;
   FRENewObjectFromBool((uint32_t)didRequestProvisional, &ret);
   return nil;
}

DEFINE_ANE_FUNCTION(processDeepLinks)
{
   TeakProcessDeepLinks();
   return nil;
}

void dispatchEvent(const uint8_t* eventCode, FREContext context, NSDictionary* userInfo)
{
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
   uint32_t numFunctions = 19;
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

   func[9].name = (const uint8_t*)"openSettingsAppToThisAppsSettings";
   func[9].functionData = NULL;
   func[9].function = &openSettingsAppToThisAppsSettings;

   func[10].name = (const uint8_t*)"getNotificationState";
   func[10].functionData = NULL;
   func[10].function = &getNotificationState;

   func[11].name = (const uint8_t*)"getAppConfiguration";
   func[11].functionData = NULL;
   func[11].function = &getAppConfiguration;

   func[12].name = (const uint8_t*)"getDeviceConfiguration";
   func[12].functionData = NULL;
   func[12].function = &getDeviceConfiguration;

   func[13].name = (const uint8_t*)"reportTestException";
   func[13].functionData = NULL;
   func[13].function = &reportTestException;

   func[14].name = (const uint8_t*)"requestProvisionalPushAuthorization";
   func[14].functionData = NULL;
   func[14].function = &requestProvisionalPushAuthorization;

   func[15].name = (const uint8_t*)"scheduleLongDistanceNotification";
   func[15].functionData = NULL;
   func[15].function = &scheduleLongDistanceNotification;

   func[16].name = (const uint8_t*)"trackEvent";
   func[16].functionData = NULL;
   func[16].function = &trackEvent;

   func[17].name = (const uint8_t*)"incrementEvent";
   func[17].functionData = NULL;
   func[17].function = &incrementEvent;

   func[18].name = (const uint8_t*)"processDeepLinks";
   func[18].functionData = NULL;
   func[18].function = &processDeepLinks;

   *functionsToSet = func;

   [[NSNotificationCenter defaultCenter] addObserverForName:TeakNotificationAppLaunch
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    dispatchEvent((const uint8_t*)"LAUNCHED_FROM_NOTIFICATION", ctx, notification.userInfo);
                                                 }];
   [[NSNotificationCenter defaultCenter] addObserverForName:TeakOnReward
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    dispatchEvent((const uint8_t*)"ON_REWARD", ctx, notification.userInfo);
                                                 }];
   [[NSNotificationCenter defaultCenter] addObserverForName:TeakForegroundNotification
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    dispatchEvent((const uint8_t*)"ON_FOREGROUND_NOTIFICATION", ctx, notification.userInfo);
                                                 }];
   [[NSNotificationCenter defaultCenter] addObserverForName:TeakAdditionalData
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    dispatchEvent((const uint8_t*)"ON_ADDITIONAL_DATA", ctx, notification.userInfo);
                                                 }];

   TeakSetLogListener(^(NSString* _Nonnull event,
                        NSString* _Nonnull level,
                        NSDictionary* _Nullable eventData) {
      dispatchEvent((const uint8_t*)"ON_LOG_EVENT", ctx, eventData);
   });
}

void AirTeakContextFinalizer(FREContext ctx) {}

void AirTeakFinalizer(void* extData) {}

void AirTeakInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
   *extDataToSet = NULL;
   *ctxInitializerToSet = &AirTeakContextInitializer;
   *ctxFinalizerToSet = &AirTeakContextFinalizer;
}
