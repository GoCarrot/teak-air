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

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;

public class Application extends android.app.Application {
    ActivityLifecycleCallbacks lifecycleCallbacks;

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);

        final String appEntryCanonicalName = base.getPackageName() + ".AppEntry";

        if (lifecycleCallbacks == null) {
            lifecycleCallbacks = new ActivityLifecycleCallbacks() {
                @Override
                public void onActivityCreated(Activity activity, Bundle bundle) {
                    if (activity.getClass().getCanonicalName().equalsIgnoreCase(appEntryCanonicalName)) {
                        Teak.onCreate(activity);
                        Teak.lifecycleCallbacks.onActivityCreated(activity, bundle);
                    }
                }

                @Override
                public void onActivityStarted(Activity activity) {
                }

                @Override
                public void onActivityResumed(Activity activity) {
                }

                @Override
                public void onActivityPaused(Activity activity) {
                }

                @Override
                public void onActivityStopped(Activity activity) {
                }

                @Override
                public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
                }

                @Override
                public void onActivityDestroyed(Activity activity) {
                }
            };
            registerActivityLifecycleCallbacks(lifecycleCallbacks);
        }
    }
}
