Android
=======
.. highlight:: xml

Set up Teak support at the Application level
--------------------------------------------
Add the following lines to your AIR app::

    <android>
        <manifestAdditions>
            <![CDATA[
                <!-- etc -->

                <application android:name="io.teak.sdk.Application">
                    <meta-data android:name="io_teak_app_id" android:value="teakYOUR_TEAK_APP_ID" />
                    <meta-data android:name="io_teak_api_key" android:value="teakYOUR_TEAK_API_KEY" />
                    <meta-data android:name="io_teak_gcm_sender_id" android:value="teakYOUR_GCM_SENDER_ID" />
                </application>

                <!-- etc -->
            ]]>
        </manifestAdditions>
    </android>

.. note:: Replace ``YOUR_TEAK_APP_ID`` with your Teak App Id, ``YOUR_TEAK_API_KEY`` with your Teak API Key, and ``YOUR_GCM_SENDER_ID`` with your GCM Sender Id.

.. warning:: Make sure to keep the 'teak' prefix on each value, I.E. ``teak12345``.

To customize the accent-color and/or icons for your notifications, use the following::

    <integer name="io_teak_notification_accent_color">0xfff15a29</integer> <!-- Color : 0xAARRGGBB -->
    <drawable name="io_teak_small_notification_icon">@drawable/icon</drawable>

.. note:: An additional value for ``io_teak_small_notification_icon`` should be placed in ``values-v21`` with a white and transparent icon for Lollipop.


What This Does
^^^^^^^^^^^^^^
This gives Teak all of the information it needs to run, and lets Teak auto-load when your application loads.

.. note:: If you are using another SDK which replaces the ``android:name`` in ``<application>`` please contact Pat for some work-around options.

Enable Debugging (for testing)
------------------------------
Add ``android:debuggable="true"`` to your ``<application>`` section::

    <android>
        <manifestAdditions>
            <![CDATA[
                <!-- etc -->

                <application android:name="io.teak.sdk.Application" android:debuggable="true">

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

    <activity android:configChanges="screenSize|smallestScreenSize|screenLayout|orientation|keyboardHidden|fontScale"
        android:label="@string/app_name"
        android:launchMode="singleTask"
        android:name=".AppEntry"
        android:screenOrientation="user"
        android:theme="@style/Theme.NoShadow"
        android:windowSoftInputMode="adjustResize|stateHidden">

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

    <receiver android:name="io.teak.sdk.Teak" android:exported="true"
        android:permission="com.google.android.c2dm.permission.SEND">
        <intent-filter>
            <action android:name="YOUR_PACKAGE_NAME.intent.TEAK_NOTIFICATION_OPENED" />
            <action android:name="YOUR_PACKAGE_NAME.intent.TEAK_NOTIFICATION_CLEARED" />
            <action android:name="com.google.android.c2dm.intent.RECEIVE" />
            <category android:name="YOUR_PACKAGE_NAME" />
        </intent-filter>
    </receiver>

    <service android:name="io.teak.sdk.InstanceIDListenerService" android:exported="false" >
        <intent-filter>
            <action android:name="com.google.android.gms.iid.InstanceID" />
        </intent-filter>
    </service>

.. note:: Replace ``YOUR_PACKAGE_NAME`` with the package name of your Android game. Make sure that for air games, you prefix the package name with "air" (if applicable to your game).

What This Does
^^^^^^^^^^^^^^
This allows Teak to receive events related to push notifications.
