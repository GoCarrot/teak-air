iOS
===
.. highlight:: xml

Add Teak settings to Info.plist
-------------------------------

Add the *TeakAppId* and *TeakApiKey* key-value pairs, and the Teak URL Scheme to the ``<InfoAdditions>`` section of your AIR XML::

    <iPhone>
        <!-- Other iPhone Configuration -->
        <InfoAdditions>
            <![CDATA[

                <!-- Other Plist Additions -->

                <key>TeakAppId</key>
                <string>YOUR_TEAK_APP_ID</string>
                <key>TeakApiKey</key>
                <string>YOUR_TEAK_API_KEY</string>

                <key>UIBackgroundModes</key>
                <array>
                   <string>remote-notification</string>
                </array>

                <key>CFBundleURLTypes</key>
                <array>
                    <dict>
                        <!-- Other URL Types -->

                        <key>CFBundleURLSchemes</key>
                        <array>
                            <string>teakYOUR_TEAK_APP_ID</string>
                        </array>
                    </dict>
                </array>
            ]]>
        </InfoAdditions>
    </iPhone>

.. note:: Replace ``YOUR_TEAK_APP_ID``, and ``YOUR_TEAK_API_KEY`` with your game's values.

Your Teak App Id and API Key can be found in the Settings for your app on the Teak dashboard:

.. warning:: TODO: Screenshot

Add Teak settings to Entitlements
---------------------------------
Add the Teak Universal Link domain to the ``<Entitlements>`` section of your AIR XML::

    <iPhone>
        <!-- Other iPhone Configuration -->
        <Entitlements>
            <![CDATA[
                <key>com.apple.developer.associated-domains</key>
                <array>
                    <string>applinks:YOUR_DOMAIN_PREFIX.jckpt.me</string>
                </array>
            ]]>
       </Entitlements>
    </iPhone>

.. note:: Replace ``YOUR_DOMAIN_PREFIX`` with the domain prefix for your game.

Your Teak domain prefix can be found in the Settings for your app on the Teak dashboard:

.. warning:: TODO: Screenshot

What This Does
--------------
These additions give the Teak SDK for iOS the credentials it needs to talk to the Teak Service, and the ability to respond to Teak deep links.

Testing It
----------
Build your AIR game for iOS, and install it on your device.

In Xcode, go to **Window > Devices** and select the connected iOS device. Then run the installed Adobe AIR application.

You will be able to see debug log output in the window by clicking on the arrow in a box along the bottom bar.

.. warning:: TODO: Screenshot

You Should See
^^^^^^^^^^^^^^
Output prefixed with Teak that display the SDK version, and 'Lifecycle' messages as well as the App Id and Api Key for your Game.

If You See
^^^^^^^^^^
::

    (null) for the App Id or Api Key

That means that the Plist additions were not added to the game configuration.

If You See
^^^^^^^^^^
No output prefixed with Teak

That means that the Teak ANE is not getting built into your game.

