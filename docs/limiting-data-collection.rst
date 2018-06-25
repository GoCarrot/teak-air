.. include:: global.rst

Limiting Data Collection
========================
.. highlight:: xml

If you would like to restrict the data that Teak collects, for all users of your game, you can specify these options in your ``AndroidManifest.xml`` for Android, and in your ``Info.plist`` for iOS.

Push Key
--------
.. warning:: If you prevent Teak from collecting the Push Key, Teak will no longer be able to send Local Notifications or Push Notifications for your game.

Android
^^^^^^^
Add the following to your ``AndroidManifest.xml`` in the ``<application>`` section::

    <meta-data android:name="io_teak_enable_push_key" android:value="false" />

iOS
^^^
Add the following to your ``Info.plist``::

    <key>TeakEnablePushKey</key>
    <false/>

Facebook Access Token
---------------------
.. warning:: If you prevent Teak from collecting the Facebook Access Token, Teak will no longer be able to corrilate users across multiple devices.

Android
^^^^^^^
Add the following to your ``AndroidManifest.xml`` in the ``<application>`` section::

    <meta-data android:name="io_teak_enable_facebook" android:value="false" />

iOS
^^^
Add the following to your ``Info.plist``::

    <key>TeakEnableFacebook</key>
    <false/>

IDFA
----
.. warning:: If you prevent Teak from collecting the Identifier For Advertisers (IDFA), Teak will no longer be able to sync audiences to Facebook Ad Audiences.

Android
^^^^^^^
Add the following to your ``AndroidManifest.xml`` in the ``<application>`` section::

    <meta-data android:name="io_teak_enable_idfa" android:value="false" />

iOS
^^^
Add the following to your ``Info.plist``::

    <key>TeakEnableIDFA</key>
    <false/>

Testing Your Data Collection Configuration
------------------------------------------
To make sure that your changes have been implemented properly, examine the debug logs.

.. highlight:: json

Search the logs for the ``configuration.data_collection`` event, you should see something like the following::

    {
        "event_type":"configuration.data_collection",
        "event_data":{
            "enableIDFA":true,
            "enableFacebookAccessToken":true,
            "enablePushKey":true
        }
    }

Check that any data collection you have disabled shows up as ``false`` instead of ``true``.
