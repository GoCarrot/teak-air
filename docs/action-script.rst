ActionScript
============

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

Scheduling a Notification from ActionScript
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To schedule a notification from your game, simply use::

    scheduleNotification(creativeId:String, defaultMessage:String, delayInSeconds:Number):void

Parameters
    ``creativeId`` - A value used to identify the message creative in the Teak CMS e.g. "daily_bonus"

    ``defaultMessage`` - The text to use in the notification if there are no modifications in the Teak CMS.

    ``delayInSeconds`` - The number of seconds from the current time before the notification should be sent.

Event
    Upon successful completion, the ``TeakEvent.NOTIFICATION_SCHEDULED`` event will be triggered.

Listen for this event by adding an event listener::

    Teak.instance.addEventListener(TeakEvent.NOTIFICATION_SCHEDULED, scheduledNotification);

And::

    private function scheduledNotification(e:TeakEvent):void
    {
        trace("Scheduled id " + e.data);
    }

The data field of the event will contain the schedule id of the notification, for use with cancelNotification.

Canceling a Notification from ActionScript
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To cancel a previously scheduled notification, use::

    cancelNotification(scheduleId:String):void

Parameters
    ``scheduleId`` - The id received from the ``TeakEvent.NOTIFICATION_SCHEDULED`` event.

Event
    Upon successful completion, the ``TeakEvent.NOTIFICATION_CANCELED event`` will be triggered.

The data field of the event will contain the schedule id of the notification that has been canceled.

Deep Linking
------------
You can use Teak to register deep links inside of your app for use in push notifications or Teak deep link URLs.

Registering a Deep Link from ActionScript
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To schedule a notification from your game, simply use::

   registerRoute(route:String, name:String, description:String, callback:Function):void

Parameters
    ``route`` - The URL pattern, including variables, that routes incoming deep links to the specified code.

    ``name`` - The name used to identify the deep link route, used in the Teak dashboard.

    ``description`` - The description of the deep link route, used in the Teak dashboard.

    ``callback`` - The function to execute when the deep link route is called. The parameters of the function are passed as an object map.

Example::

    Teak.instance.registerRoute("/store/:sku", "Store", "Open the store to an SKU", function(parameters:Object):void {
        trace("SKU: " + parameters.sku);
    });

The ``parameters`` argument contains the URL query parameters and any variables built into the deep link route.
