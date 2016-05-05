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

import java.util.HashMap;
import java.util.Map;

import java.lang.reflect.Proxy;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationHandler;

import android.util.Log;

import android.content.Intent;
import android.content.res.Configuration;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.AndroidActivityWrapper.ActivityState;

public class ExtensionContext extends FREContext
{
    public ExtensionContext() {
        if (Teak.isDebug) {
            Log.d(Teak.LOG_TAG, "ANE Context created.");
        }

        try {
            Class<?> activityResultCallbackClass = Class.forName("com.adobe.air.AndroidActivityWrapper$ActivityResultCallback");
            Class<?> stateChangeCallbackClass = Class.forName("com.adobe.air.AndroidActivityWrapper$StateChangeCallback");
            this.activityResultCallbackProxy = Proxy.newProxyInstance(activityResultCallbackClass.getClassLoader(), new Class[] { activityResultCallbackClass }, new ANEMagicInvocationHandler());
            this.stateChangeCallbackProxy = Proxy.newProxyInstance(stateChangeCallbackClass.getClassLoader(), new Class[] { stateChangeCallbackClass }, new ANEMagicInvocationHandler());

            this.aaw = AndroidActivityWrapper.GetAndroidActivityWrapper();
            Method m = AndroidActivityWrapper.class.getMethod("addActivityResultListener", activityResultCallbackClass);
            m.invoke(aaw, this.activityResultCallbackProxy);
            m = AndroidActivityWrapper.class.getMethod("addActivityStateChangeListner", stateChangeCallbackClass);
            m.invoke(aaw, this.stateChangeCallbackProxy);
        } catch (Exception e) {
            Log.e(Teak.LOG_TAG, "Reflection error: " + Log.getStackTraceString(e));
        }
    }
    
    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
        functionMap.put("_init", new InitFunction());
        functionMap.put("identifyUser", new IdentifyUserFunction());
        return functionMap;
    }

    class ANEMagicInvocationHandler implements InvocationHandler {
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

            // toString()
            if (method.getName().equals("toString")) {
                return "io.teak.sdk.ExtensionContext$ANEMagicInvocationHandler";
            } else if(method.getName().equals("equals")) {
                return (args[0].hashCode() == this.hashCode());

            } else if(method.getName().equals("onActivityStateChanged")) {
                ActivityState state = (ActivityState) args[0];

                if (Teak.isDebug) {
                    Log.d(Teak.LOG_TAG, "onActivityStateChanged - " + state.toString());
                }

                switch (state) {
                    // TODO: RESTARTED check for teak notif id?
                    case RESUMED: {
                        Teak.lifecycleCallbacks.onActivityResumed(getActivity());
                    }
                    break;
                    case PAUSED: {
                        Teak.lifecycleCallbacks.onActivityPaused(getActivity());
                    }
                    break;
                    case DESTROYED: {
                        Teak.lifecycleCallbacks.onActivityDestroyed(getActivity());
                    }
                    break;
                }

                return null;
            // TODO: Teak.onActivityResult(requestCode, resultCode, intent);
            } else {
                Log.d(Teak.LOG_TAG, "ANEMagicInvocationHandler");
                Log.d(Teak.LOG_TAG, "   method: " + method.getName());
                Log.d(Teak.LOG_TAG, "     args: " + args.toString());
                return null;
            }
        }
    }

    @Override 
    public void dispose() {
        if (Teak.isDebug) {
            Log.d(Teak.LOG_TAG, "ANE Context destroyed.");
        }

        if (this.aaw != null) {
            try {
                Class<?> activityResultCallbackClass = Class.forName("com.adobe.air.AndroidActivityWrapper$ActivityResultCallback");
                Method m = AndroidActivityWrapper.class.getMethod("removeActivityResultListener", activityResultCallbackClass);
                m.invoke(this.aaw, this.activityResultCallbackProxy);
                m = AndroidActivityWrapper.class.getMethod("removeActivityStateChangeListner", activityResultCallbackClass);
                m.invoke(this.aaw, this.stateChangeCallbackProxy);
                this.aaw = null;
            } catch (Exception e) {
                Log.e(Teak.LOG_TAG, "Reflection error: " + Log.getStackTraceString(e));
            }
        }
    }

    private AndroidActivityWrapper aaw;
    private Object activityResultCallbackProxy;
    private Object stateChangeCallbackProxy;
}
