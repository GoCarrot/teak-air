.. _Before You Start:

Before You Start
================
It would be frustrating to start integrating the Teak SDK, only to find out you don't have credentials to test the push notifications, so before you start here's what you need to make things go smoothly.

iOS
---
In order to send push notifications to your game on iOS, Teak needs your Apple Push Notification Service (APNS) Certificates.

You will need an Administrator on your Apple Developer account for this step, and the will need to use a Mac in order to perform this step.

`Follow these instructions to create your APNS certificates and provide them to Teak <https://teak.readthedocs.io/en/latest/apple-apns.html>`_.

Android
-------
In order to send push notifications to your game on Android, Teak needs the Server Key and Sender ID from your Firebase project.

You will need Editor or Owner role on the Firebase project  in order to view/create server keys for Cloud Messaging.

`Follow these instructions to get your Server Key and Sender ID <https://teak.readthedocs.io/en/latest/firebase-gcm.html>`_.
