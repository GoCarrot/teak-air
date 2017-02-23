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
package io.teak.sdk;

import java.util.Map;
import java.util.HashMap;

import android.os.Bundle;

import android.util.Log;

import android.content.Intent;
import android.content.Context;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;

import org.json.JSONObject;

import android.support.v4.content.LocalBroadcastManager;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class ExtensionContext extends FREContext {
    private static final String LOG_TAG = "Teak:Air:ExtensionContext";

    BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (TeakNotification.LAUNCHED_FROM_NOTIFICATION_INTENT.equals(action)) {
                String eventData = "";
                Bundle bundle = intent.getExtras();
                try {
                    HashMap<String, Object> eventDataDict = new HashMap<String, Object>();

                    HashMap<String, Object> teakReward = (HashMap<String, Object>) bundle.getSerializable("teakReward");
                    if (teakReward != null) {
                        eventDataDict.put("reward", teakReward);
                    }

                    String teakDeepLink = bundle.getString("teakDeepLink");
                    if (teakDeepLink != null) {
                        eventDataDict.put("deepLink", teakDeepLink);
                    }

                    eventData = new JSONObject(eventDataDict).toString();
                } catch(Exception e) {
                    Log.e(LOG_TAG, Log.getStackTraceString(e));
                } finally {
                    Extension.context.dispatchStatusEventAsync("LAUNCHED_FROM_NOTIFICATION", eventData);
                }
            }
        }
    };

    public ExtensionContext() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(TeakNotification.LAUNCHED_FROM_NOTIFICATION_INTENT);
        Teak.localBroadcastManager.registerReceiver(broadcastReceiver, filter);
    }

    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
        functionMap.put("identifyUser", new IdentifyUserFunction());
        functionMap.put("_log", new LogFunction());
        functionMap.put("scheduleNotification", new ScheduleNotificationFunction(false));
        functionMap.put("cancelNotification", new ScheduleNotificationFunction(true));
        functionMap.put("registerRoute", new RegisterRouteFunction());
        return functionMap;
    }

    @Override 
    public void dispose() {
    }
}
