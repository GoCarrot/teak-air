.. Teak for Adobe AIR documentation master file, created by
   sphinx-quickstart on Thu Aug 31 12:44:59 2017.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Getting started with Teak in Adobe AIR
======================================

.. toctree::
    :maxdepth: 2
    :hidden:

    setup
    ios
    android
    action-script
    adm

Hey there!

We know integrating SDKs isn't your favorite thing in the world, but we're going to make this as painless as possible.

We're going to give you step-by-step instructions for integrating Teak with Adobe AIR for iOS and Android, how to test your integration, and how to fix errors you may run into.

.. tip:: You can always ask us for help, don't be shy.

Here is an overview of what we'll be doing.

Setup
-----
* Add the Teak ANE

iOS
---
* Add Teak Plist and entitlements additions to your ``app.xml``

Android
-------
* Add Teak manifest additions to your ``app.xml``
* Call Teak from your billing activity

ActionScript
------------
* Call ``identifyUser``
* Listen for reward events
* Listen for push notifications
* Listen for deep links
* 🎉 Pat yourself on the back, because you did it 🎉

Amazon Device Support
---------------------
* Add ADM manifest modifications to your ``app.xml``
* Add ``api_key.txt`` to your assets
* Set up your un-pack/re-pack build steps
