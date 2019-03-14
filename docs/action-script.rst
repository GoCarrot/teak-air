ActionScript
============
.. highlight:: as3

Tell Teak how to Identify The Current User
------------------------------------------
Call Teak's ``identifyUser`` function and pass it a string which uniquely identifies the current user.

This should be the same way your back-end identifies users. This should be called as soon as you first know the user id.

::

    Teak.instance.identifyUser("a unique user identifier");

What This Does
^^^^^^^^^^^^^^
Identifying the user will allow Teak to start sending information to the remote Teak service and allow Teak to function.

Testing It
^^^^^^^^^^
You can now run your game on either Android or iOS and look at the log.

You Should See a Line Containing::

    "event_type":"identify_user" <...>
        "event_data":{"userId":"a unique user identifier"}

Ask for Push Notification Permissions
-------------------------------------
Call the ``registerForNotifications`` function on Teak to request push notification permissions on iOS. On Android this will be ignored automatically, there is no need to special case your code.

This should ideally be called after asking the user if they want to be notified when something completes or new information is available.

::

    Teak.instance.registerForNotifications()

What This Does
^^^^^^^^^^^^^^
This will pop up the system dialog requesting push notification permissions on iOS.

On Android it will do nothing.

Testing It
^^^^^^^^^^
Build your game and launch it on iOS, then check to see if the system dialog is displayed.

.. note:: If permissions have been granted or denied, you need to delete the app from the phone and then re-install it in order for the prompt to be shown again.

.. important:: In non-debug builds, there is a timeout of 1 day for re-requesting push permissions even if the app is deleted. Be aware of this during testing.

Listen for Push Notification Events
-----------------------------------
Add an event listener for ``TeakEvent.LAUNCHED_FROM_NOTIFICATION`` in order to detect when your game has been launched by a push notification.

For example::

    Teak.instance.addEventListener(TeakEvent.LAUNCHED_FROM_NOTIFICATION, launchedFromNotification);

And::

    private function launchedFromNotification(e:TeakEvent):void
    {
        // e.data contains a JSON blob of push notification parameters (it will likely be empty)
    }

What This Does
^^^^^^^^^^^^^^
This allows you to know when your game was launched, or re-launched from a push notification.

Listen for Reward Events
------------------------
Add an event listener for ``TeakEvent.ON_REWARD`` in order to detect when your game has processed a Teak reward from any source (push notification or deep link).

For example::

    Teak.instance.addEventListener(TeakEvent.ON_REWARD, onReward);

And::

    private function onReward(e:TeakEvent):void
    {
        // e.data contains a JSON blob containing reward information
        // eg
        // {
        //    "teakRewardId":"<reward id as string>",
        //    "status":"grant_reward",
        //    "reward": {
        //       "coins": 1000,
        //    }
        // }
    }

What This Does
^^^^^^^^^^^^^^
This allows you to use Teak to incentivize users to open push notifications and deep links by providing rewards.

Local Notifications
-------------------
You can use Teak to schedule notifications for the future.

.. note:: You get the full benefit of Teak's analytics, A/B testing, and Content Management System.

Scheduling a Local Notification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To schedule a notification from your game, use::

    Teak.instance.scheduleNotification(creativeId:String, defaultMessage:String,
        delayInSeconds:Number):void

Parameters
    :creativeId: A value used to identify the message creative in the Teak CMS e.g. "daily_bonus"

    :defaultMessage: The text to use in the notification if there are no modifications in the Teak CMS.

    :delayInSeconds: The number of seconds from the current time before the notification should be sent.

Event
    Upon successful completion, the ``TeakEvent.NOTIFICATION_SCHEDULED`` event will be triggered.

Listen for this event by adding an event listener::

    Teak.instance.addEventListener(TeakEvent.NOTIFICATION_SCHEDULED, scheduledNotification);

And::

    private function scheduledNotification(e:TeakEvent):void
    {
        trace("Scheduled id " + e.data);
    }

The data field of the event will contain the schedule id of the notification, for use with ``cancelNotification()``.

.. important:: The maximum delay for a Local Notification is 30 days.

Scheduling a Long-Distance Notification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To schedule a notification from your game that will be delivered to another user, use::

    Teak.instance.scheduleLongDistanceNotification(creativeId:String, delayInSeconds:Number,
        userIds:Array):void

Parameters
    :creativeId: A value used to identify the message creative in the Teak CMS e.g. "daily_bonus"

    :delayInSeconds: The number of seconds from the current time before the notification should be sent.

    :userIds: An array of user ids to which the notification should be delivered

Event
    Upon successful completion, the ``TeakEvent.LONG_DISTANCE_NOTIFICATION_SCHEDULED`` event will be triggered.

Listen for this event by adding an event listener::

    Teak.instance.addEventListener(TeakEvent.LONG_DISTANCE_NOTIFICATION_SCHEDULED,
        scheduledLongDistanceNotification);

And::

    private function scheduledLongDistanceNotification(e:TeakEvent):void
    {
        trace("Scheduled ids " + e.data);
    }

The data field of the event will contain a JSON encoded array of scheduled ids, for use with ``cancelNotification()``.

.. important:: The maximum delay for a Long-Distance Notification is 30 days.

Canceling a Local Notification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To cancel a previously scheduled local notification, use::

    Teak.instance.cancelNotification(scheduleId:String):void

Parameters
    :scheduleId: Passing the id received from the ``TeakEvent.NOTIFICATION_SCHEDULED`` event will cancel that specific notification; passing the ``creativeId`` used to schedule the notification will cancel **all** scheduled notifications with that creative id for the user

Event
    Upon successful completion, the ``TeakEvent.NOTIFICATION_CANCELED event`` will be triggered.

The data field of the event will contain the schedule id of the notification that has been canceled.

Canceling all Local Notifications
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To cancel all previously scheduled local notifications, use::

    Teak.instance.cancelAllNotifications():void

Event
    Upon successful completion, the ``TeakEvent.NOTIFICATION_CANCEL_ALL`` event will be triggered. ``event.status``
    will be one of the following:

        :ok: The request was succesfully processed

        :invalid_device: The current device has not been registered with Teak. This is likely caused by ```identifyUser()``` not being called

        :error.internal: An unexpected error occurred and the request should be retried

    If status is ``ok`` then event.data will be a JSON encoded array. Each entry in the array will be an Object containing:

        :scheduleId: The id originally received from the ``TeakEvent.NOTIFICATION_SCHEDULED`` event.

        :creativeId: The the ``creativeId`` originally passed to ``scheduleNotification()`` or ``scheduleLongDistanceNotification()``

.. note:: This call is processed asynchronously. If you immediately call ``scheduleNotification`` after calling ``cancelAllNotifications`` it is possible for your newly scheduled notification to also be canceled. We recommend waiting until ``TeakEvent.NOTIFICATION_CANCEL_ALL`` has fired before scheduling any new notifications.

Determining if User Has Disabled Push Notifications
---------------------------------------------------
You can use Teak to get the state of push notifications for your app.

If notifications are disabled, you can prompt them to re-enable them on the settings page for the app, and use Teak to go directly the settings for your app.

.. _get-notification-state:

Get Notification State
^^^^^^^^^^^^^^^^^^^^^^
To determine the state of push notifications, use::

    Teak.instance.getNotificationState():TeakNotificationState

Return
    :UnableToDetermine: Unable to determine the notification state.

    :Enabled: Notifications are enabled, your app can send push notifications.

    :Disabled: Notifications are disabled, your app cannot send push notifications.

    :Provisional: Provisional notifications are enabled, your app can send notifications but they will only display in the Notification Center (iOS 12+ only).

    :NotRequested: The user has not been asked to authorize push notifications (iOS only).

Example::

    if (Teak.instance.getNotificationState() === TeakNotificationState.Disabled) {
        // Show a button that will let users open the settings
    }

Opening the Settings for Your App
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If you want to show the settings for your app, use::

    Teak.instance.openSettingsAppToThisAppsSettings():Boolean

This function will return ``false`` if Teak was not able to open the settings, ``true`` otherwise.

Example::

    // ...
    // When a user presses a button indicating they want to change their notification settings
    Teak.instance.openSettingsAppToThisAppsSettings()

.. user-attributes:

User Attributes
---------------
Teak can store up to 16 numeric, and 16 string attributes per user. These attributes can then be used for targeting.

You do not need to register the attribute in the Teak Dashboard prior to sending them from your game, however you will need to enable them in the Teak Dashboard before using them in targeting.

Numeric Attributes
^^^^^^^^^^^^^^^^^^
To set a numeric attribute, use::

    Teak.instance.setNumericAttribute(key:String, value:Number):void

Example::

    Teak.instance.setNumericAttribute("coins", new_coin_balance);

String Attributes
^^^^^^^^^^^^^^^^^
To set a string attribute, use::

    Teak.instance.setStringAttribute(key:String, value:String):void

Example::

    Teak.instance.setStringAttribute("last_slot", "amazing_slot_name");

Deep Linking
------------
You can use Teak to register deep links inside of your app for use in push notifications or Teak deep link URLs.

Registering a Deep Link from ActionScript
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To schedule a notification from your game, simply use::

   Teak.instance.registerRoute(route:String, name:String, description:String, callback:Function):void

Parameters
    :route: The URL pattern, including variables, that routes incoming deep links to the specified code.

    :name: The name used to identify the deep link route, used in the Teak dashboard.

    :description: The description of the deep link route, used in the Teak dashboard.

    :callback: The function to execute when the deep link route is called. The parameters of the function are passed as an object map.

Example::

    Teak.instance.registerRoute("/store/:sku", "Store", "Open the store to an SKU", function(parameters:Object):void {
        trace("SKU: " + parameters.sku);
    });

The ``parameters`` argument contains the URL query parameters and any variables built into the deep link route.

When Are Deep Links Executed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Deep links are passed to an application as part of the launch. The Teak SDK holds onto the deep link information and waits until your app has finished launching, and initializing.

Deep links will get processed the sooner of:

* Your app calls ``identifyUser``
* Your app calls ``processDeepLinks``

``processDeepLinks`` is provided so that you can signify that deep links should be processed earlier than your call to ``identifyUser`` or so that you can still process deep links in the case of a user opting out of tracking.
