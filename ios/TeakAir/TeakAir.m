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
extern const char* TeakLaunchedFromTeakNotifId();
extern void* TeakNotificationFromTeakNotifId(const char* teakNotifId);
extern BOOL TeakNotificationHasReward(void* notif);
extern void* TeakNotificationConsume(void* notif);
extern BOOL TeakRewardIsCompleted(void* notif);
extern int TeakRewardGetStatus(void* reward);
extern const char* TeakRewardGetJson(void* reward);

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
      NSLog(@"[Teak] %s", (const char*)userId);
   }

   return nil;
}

void checkTeakNotifLaunch(FREContext context)
{
   const uint8_t* eventCode = (const uint8_t*)"LAUNCHED_FROM_NOTIFICATION";
   const uint8_t* eventLevelEmpty = (const uint8_t*)"";

   const char* teakNotifId = TeakLaunchedFromTeakNotifId();
   if(teakNotifId != nil)
   {
      void* notif = TeakNotificationFromTeakNotifId(teakNotifId);
      if(notif != nil)
      {
         if(TeakNotificationHasReward(notif))
         {
            void* reward = TeakNotificationConsume(notif);
            if(reward != nil)
            {
               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                  while(!TeakRewardIsCompleted(reward))
                  {
                     sleep(1);
                  }

                  if(TeakRewardGetStatus(reward) == 0)
                  {
                     const uint8_t* rewardJson = (const uint8_t*)TeakRewardGetJson(reward);
                     FREDispatchStatusEventAsync(context, eventCode, rewardJson);
                     NSLog(@"Dispatching WITH reward json: %s", rewardJson);
                  }
                  else
                  {
                     FREDispatchStatusEventAsync(context, eventCode, eventLevelEmpty);
                  }
               });
            }
            else
            {
               FREDispatchStatusEventAsync(context, eventCode, eventLevelEmpty);
            }
         }
         else
         {
            FREDispatchStatusEventAsync(context, eventCode, eventLevelEmpty);
         }
      }
   }
}

void AirTeakContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
   uint32_t numFunctions = 2;
   *numFunctionsToTest = numFunctions;
   FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * numFunctions);

   func[0].name = (const uint8_t*)"identifyUser";
   func[0].functionData = NULL;
   func[0].function = &identifyUser;

   func[1].name = (const uint8_t*)"_log";
   func[1].functionData = NULL;
   func[1].function = &_log;

   *functionsToSet = func;

   [[NSNotificationCenter defaultCenter] addObserverForName:TeakNotificationAppLaunch
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification* notification) {
                                                    checkTeakNotifLaunch(ctx);
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
