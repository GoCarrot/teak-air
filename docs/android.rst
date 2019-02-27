Android
=======
.. highlight:: xml

.. _android-dependencies:

Android Dependencies
--------------------
Teak for Android depends on Firebase Messaging (FCM) and Android Support v4. These dependencies are not bundled with the Teak ANE.

If you are not already using an ANE which provides these, we suggest using the ANE dependencies from MyFlashLabs, located at: https://github.com/myflashlab/common-dependencies-ANE

The dependencies in your App XML should look like this::

    <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.arch</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.core</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.v4</extensionID>

    <extensionID>com.myflashlab.air.extensions.dependency.firebase.common</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.firebase.iid</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.firebase.messaging</extensionID>

    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.ads</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.base</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.basement</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.tasks</extensionID>

You will also need to manually add the following to your AIR app:

.. code-block:: xml
   :emphasize-lines: 6, 7, 12-41

    <android>
        <manifestAdditions>
            <![CDATA[
                <!-- etc -->

                <!-- Required by older versions of Google Play services to create IID tokens -->
                <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />

                <application android:name="io.teak.sdk.wrapper.Application">
                    <!-- etc -->

                    <!-- These would have been added by Firebase manifest merger -->
                    <service android:name="com.google.firebase.components.ComponentDiscoveryService"
                             android:exported="false">
                        <meta-data
                            android:name="com.google.firebase.components:com.google.firebase.iid.Registrar"
                            android:value="com.google.firebase.components.ComponentRegistrar" />
                    </service>

                    <receiver android:name="com.google.firebase.iid.FirebaseInstanceIdReceiver"
                              android:exported="true"
                              android:permission="com.google.android.c2dm.permission.SEND">
                        <intent-filter>
                            <action android:name="com.google.android.c2dm.intent.RECEIVE" />
                        </intent-filter>
                    </receiver>

                    <service android:name="com.google.firebase.iid.FirebaseInstanceIdService"
                             android:exported="true">
                        <intent-filter android:priority="-500">
                            <action android:name="com.google.firebase.INSTANCE_ID_EVENT" />
                        </intent-filter>
                    </service>

                    <service android:name="com.google.firebase.messaging.FirebaseMessagingService"
                             android:exported="true">
                        <intent-filter android:priority="-500">
                            <action android:name="com.google.firebase.MESSAGING_EVENT" />
                        </intent-filter>
                    </service>
                    <!-- End Firebase -->

                    <!-- This would have been added by the Firebase JobDispatcher manifest merge -->
                    <service
                        android:name="com.firebase.jobdispatcher.GooglePlayReceiver"
                        android:exported="true"
                        android:permission="com.google.android.gms.permission.BIND_NETWORK_TASK_SERVICE" >
                        <intent-filter>
                            <action android:name="com.google.android.gms.gcm.ACTION_TASK_READY" />
                        </intent-filter>
                    </service>
                    <!-- End Firebase JobDispatcher -->

                    <!-- etc -->
                </application>

                <!-- etc -->
            ]]>
        </manifestAdditions>
    </android>

Set up Teak support at the Application level
--------------------------------------------
Add the following lines to your AIR app:

.. code-block:: xml
   :emphasize-lines: 6-11

    <android>
        <manifestAdditions>
            <![CDATA[
                <!-- etc -->

                <application android:name="io.teak.sdk.wrapper.Application">
                    <meta-data android:name="io_teak_app_id" android:value="teakYOUR_TEAK_APP_ID" />
                    <meta-data android:name="io_teak_api_key" android:value="teakYOUR_TEAK_API_KEY" />
                    <meta-data android:name="io_teak_gcm_sender_id" android:value="teakYOUR_GCM_SENDER_ID" />
                    <meta-data android:name="io_teak_firebase_app_id" android:value="teakYOUR_FIREBASE_APP_ID" />
                </application>

                <!-- etc -->
            ]]>
        </manifestAdditions>
    </android>

.. note:: Replace ``YOUR_TEAK_APP_ID`` with your Teak App Id, ``YOUR_TEAK_API_KEY`` with your Teak API Key, ``YOUR_GCM_SENDER_ID`` with your GCM Sender Id, and ``YOUR_FIREBASE_APP_ID`` with your Firebase App Id.

        (`How to find your GCM Sender Id <https://teak.readthedocs.io/en/latest/firebase-gcm.html>`_)

        (`How to find your Firebase App Id <https://teak.readthedocs.io/en/latest/firebase-app-id.html>`_)

.. warning:: Make sure to keep the 'teak' prefix on each value, I.E. ``teak12345``.


What This Does
^^^^^^^^^^^^^^
This gives Teak all of the information it needs to run, and lets Teak auto-load when your application loads.

.. note:: If you are using another SDK which replaces the ``android:name`` in ``<application>`` please contact Pat for some work-around options.

Enable Debugging (for testing)
------------------------------
Add ``android:debuggable="true"`` to your ``<application>`` section:

.. code-block:: xml
   :emphasize-lines: 6

    <android>
        <manifestAdditions>
            <![CDATA[
                <!-- etc -->

                <application android:name="io.teak.sdk.wraper.Application" android:debuggable="true">

                <!-- etc -->
            ]]>
        </manifestAdditions>
    </android>

What This Does
^^^^^^^^^^^^^^
Teak will automatically out verbose information to the debug log when it is running in a debuggable Android game.

.. important:: Remove this from your game when not debugging.


Testing It
^^^^^^^^^^
Install and run the game on your Android device, while looking at the debug log.

You can see the debug log by using the 'adb' command::

    adb logcat

You can also use Android Studio to view log output and it makes filtering output easy.

You Should See
^^^^^^^^^^^^^^
Output prefixed with Teak that display the SDK version, and 'Lifecycle' messages as well as the App Id and Api Key for your Game.

If You See
^^^^^^^^^^
No output prefixed with Teak

Talk to Pat via HipChat or email, and give him the build log, and device debug log.

Call Teak from Your Billing Activity
------------------------------------
.. highlight:: java

Add the following to the ``onActivityResult`` of your billing activity::

    try {
        Class<?> cls = Class.forName("io.teak.sdk.Teak");
        if (cls != null) {
            Method m = cls.getMethod("onActivityResult", int.class, int.class, Intent.class);
            m.invoke(null, requestCode, resultCode, data);
        }
    } catch(Exception ignored){
    }

What This Does
^^^^^^^^^^^^^^
This makes sure that Teak can track the purchase events in your game.

.. highlight:: xml

Add Teak Deep Link Filters
--------------------------
Add the following to the ``<application>`` section of your AIR XML::

    <activity>
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>

        <intent-filter android:autoVerify="true" >
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:host="YOUR_DOMAIN_PREFIX.jckpt.me"
                android:scheme="http" />
            <data
                android:host="YOUR_DOMAIN_PREFIX.jckpt.me"
                android:scheme="https" />
        </intent-filter>

        <intent-filter>
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:host="*"
                android:scheme="teakYOUR_TEAK_APP_ID" />
        </intent-filter>
    </activity>

.. note:: Replace ``YOUR_DOMAIN_PREFIX`` with the domain prefix for your game. Replace ``YOUR_TEAK_APP_ID`` with the Teak App Id for your game.

What This Does
^^^^^^^^^^^^^^
This tells Android that your game will handle deep links managed by Teak campaigns.

Testing It
^^^^^^^^^^
Use the ``adb`` tool to launch your app from a deep link::

    shell am start -W -a android.intent.action.VIEW -d https://YOUR_DOMAIN_PREFIX.jckpt.me/ YOUR_BUNDLE_ID

You Should See
^^^^^^^^^^^^^^
Your app launches.

If your app does not launch, check to make sure your manifest additions are correct.

Add the Teak Push Notification Receiver to your AIR XML
-------------------------------------------------------
Add the following to the ``<application>`` section::

    <!-- Teak Broadcast Receiver -->
    <receiver android:name="io.teak.sdk.Teak" android:exported="false">
        <intent-filter>
            <action android:name="YOUR_PACKAGE_NAME.intent.TEAK_NOTIFICATION_OPENED" />
            <action android:name="YOUR_PACKAGE_NAME.intent.TEAK_NOTIFICATION_CLEARED" />
            <category android:name="YOUR_PACKAGE_NAME" />
        </intent-filter>
    </receiver>

    <!-- Teak error reporter -->
    <service android:name="io.teak.sdk.service.RavenService"
             android:process=":teak.raven"
             android:exported="false"/>

    <!-- Device state background service for minimizing power consumption -->
    <service android:name="io.teak.sdk.service.DeviceStateService"
             android:process=":teak.device_state"
             android:exported="false"/>

    <!-- Job service, Android O and higher -->
    <service android:name="io.teak.sdk.service.JobService"
             android:permission="android.permission.BIND_JOB_SERVICE"
             android:exported="true"/>

    <!-- FCM ID Listener Service -->
    <service android:name="io.teak.sdk.push.FCMPushProvider"
             android:stopWithTask="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
            <action android:name="com.google.firebase.INSTANCE_ID_EVENT" />
        </intent-filter>
    </service>


.. note:: Replace ``YOUR_PACKAGE_NAME`` with the package name of your Android game. Make sure that for air games, you prefix the package name with "air" (if applicable to your game).

What This Does
^^^^^^^^^^^^^^
This allows Teak to receive events related to push notifications.

Set Notification Icons for your Game
------------------------------------
To specify the icon displayed in the system tray, and at the top of the notification, specify these resources.

You will need two versions of this file. One located in ``values`` and the other located in ``values-v21``::

    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <!-- The tint-color for your silouette icon, format is: 0xAARRGGBB -->
        <integer name="io_teak_notification_accent_color">0xfff15a29</integer>

        <!-- Icons should be white and transparent, and processed with Android Asset Studio -->
        <drawable name="io_teak_small_notification_icon">@drawable/YOUR_ICON_FILE_NAME</drawable>
    </resources>

The file in ``values`` should point to a full-color icon, for devices running less than Android 5, and the file in ``values-v21`` should point to a white and transparent PNG for Android 5 and above.

.. important:: To make sure that your white and transparent PNG shows up properly, use :doc:`Android Asset Studio's Notification icon generator <android/notification-icon>`.
