.. include:: global.rst

.. highlight:: xml

Migrating to FCM and Teak 2.0
=============================
GCM was deprecated April 10, 2018, and will be removed "as soon as April 11, 2019" `according to Google <https://developers.google.com/cloud-messaging/faq>`_.

:Since: 2.0.0

The Teak SDK no longer supports GCM, but we're going to make your migration to FCM as painless as possible.

Update to at least AIR 29
-------------------------
If you are using a lower version of AIR, you'll need to update to AIR 29.

Permissions
-----------
Remove these permissions from your AIR App::

    <permission android:name="YOUR_BUNDLE_ID.permission.C2D_MESSAGE" android:protectionLevel="signature"/>
    <uses-permission android:name="YOUR_BUNDLE_ID.permission.C2D_MESSAGE"/>

But make sure you keep::

    <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />

It is required by older versions of Google Play services to create IID tokens.

Add Your Firebase App Id
------------------------
Add your Firebase App Id to the section where you configure your Teak values, it should look something like this:

.. code-block:: xml
   :emphasize-lines: 4

    <meta-data android:name="io_teak_app_id" android:value="teakYOUR_TEAK_APP_ID" />
    <meta-data android:name="io_teak_api_key" android:value="teakYOUR_TEAK_API_KEY" />
    <meta-data android:name="io_teak_gcm_sender_id" android:value="teakYOUR_GCM_SENDER_ID" />
    <meta-data android:name="io_teak_firebase_app_id" android:value="teakYOUR_FIREBASE_APP_ID" />

.. note:: Replace ``YOUR_FIREBASE_APP_ID`` with your Firebase App Id.

.. warning:: Make sure to keep the 'teak' prefix on each value, I.E. ``teak12345``.

Change the Teak Receiver
------------------------
Right now you will have something which looks like this:

.. code-block:: xml
   :emphasize-lines: 2,3,7,8

    <receiver android:name="io.teak.sdk.Teak"
              android:exported="true"
              android:permission="com.google.android.c2dm.permission.SEND">
        <intent-filter>
            <action android:name="YOUR_BUNDLE_ID.intent.TEAK_NOTIFICATION_OPENED" />
            <action android:name="YOUR_BUNDLE_ID.intent.TEAK_NOTIFICATION_CLEARED" />
            <action android:name="com.google.android.c2dm.intent.RECEIVE" />
            <action android:name="com.google.android.c2dm.intent.REGISTRATION" />
            <category android:name="YOUR_BUNDLE_ID" />
        </intent-filter>
    </receiver>

Remove the highlighted lines, so that you have::

    <receiver android:name="io.teak.sdk.Teak" android:exported="false">
        <intent-filter>
            <action android:name="YOUR_BUNDLE_ID.intent.TEAK_NOTIFICATION_OPENED" />
            <action android:name="YOUR_BUNDLE_ID.intent.TEAK_NOTIFICATION_CLEARED" />
            <category android:name="YOUR_BUNDLE_ID" />
        </intent-filter>
    </receiver>

Add the Teak FCM Service
------------------------
Add the following service::

    <service android:name="io.teak.sdk.push.FCMPushProvider"
             android:stopWithTask="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
            <action android:name="com.google.firebase.INSTANCE_ID_EVENT" />
        </intent-filter>
    </service>

Update your Dependencies
------------------------
Finally, you'll need to update your dependencies.

FCM and GCM dependencies cannot live alongside each other, so remove your GCM dependencies, and make sure that any other SDKs you use do not rely on GCM.

The new dependencies, as well as suggested ANEs can be found here: :ref:`android-dependencies`.