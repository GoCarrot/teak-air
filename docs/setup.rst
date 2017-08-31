Setup
=====
.. highlight:: xml

Download the ANE and Add to <extensions>
----------------------------------------
Get the Teak latest ANE from https://s3.amazonaws.com/teak-build-artifacts/air/io.teak.sdk.Teak.ane and add it to your Adobe AIR XML build file in the <extensions> area::

    <?xml version="1.0" encoding="utf-8" standalone="no"?>
    <application xmlns="http://ns.adobe.com/air/application/4.0">

        <!-- Rest of the application config -->

        <extensions>
            <extensionID>io.teak.sdk.Teak</extensionID>
            <!-- Other extensions -->
        </extensions>
    </application>

What This Does
^^^^^^^^^^^^^^
This adds the files needed for Teak to work with your AIR game, including the native SDKs and ActionScript files.
