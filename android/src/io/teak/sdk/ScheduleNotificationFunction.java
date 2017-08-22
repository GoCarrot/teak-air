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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

import java.util.concurrent.Future;

public class ScheduleNotificationFunction implements FREFunction {
    boolean _isCancel;

    public ScheduleNotificationFunction(boolean isCancel) {
        _isCancel = isCancel;
    }

    @Override
    public FREObject call(FREContext context, FREObject[] argv) {
        try {
            final Future<String> future = _isCancel ? 
                TeakNotification.cancelNotification(argv[0].getAsString()) :
                TeakNotification.scheduleNotification(argv[0].getAsString(), argv[1].getAsString(), (long)argv[2].getAsDouble());
            if (future != null) {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            String teakNotifId = future.get();
                            Extension.context.dispatchStatusEventAsync(_isCancel ? "NOTIFICATION_CANCELED" : "NOTIFICATION_SCHEDULED", teakNotifId);
                        } catch(Exception e) {
                            Teak.log.exception(e);
                        }
                    }
                }).start();
            }
        } catch(Exception e) {
            Teak.log.exception(e);
        }
        return null;
    }
}
