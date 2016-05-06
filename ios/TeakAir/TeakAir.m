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

@import UIKit; // Hax

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

// From TeakHooks.m
extern void Teak_Plant(Class appDelegateClass, NSString* appId, NSString* appSecret);

// From TeakCExtern.m
extern void TeakIdentifyUser(const char* userId);

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

DEFINE_ANE_FUNCTION(_init)
{
   return nil;
}

void AirTeakContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
   uint32_t numFunctions = 2;
   *numFunctionsToTest = numFunctions;
   FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * numFunctions);

   func[0].name = (const uint8_t*)"identifyUser";
   func[0].functionData = NULL;
   func[0].function = &identifyUser;

   func[1].name = (const uint8_t*)"_init";
   func[1].functionData = NULL;
   func[1].function = &_init;

   *functionsToSet = func;
}

void AirTeakContextFinalizer(FREContext ctx) {}

void AirTeakFinalizer(void* extData) {}

void AirTeakInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
   *extDataToSet = NULL;
   *ctxInitializerToSet = &AirTeakContextInitializer;
   *ctxFinalizerToSet = &AirTeakContextFinalizer;
}
