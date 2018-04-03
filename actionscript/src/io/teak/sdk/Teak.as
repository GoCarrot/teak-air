/* Teak -- Copyright (C) 2016 GoCarrot Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.teak.sdk
{
	import flash.external.ExtensionContext;

	import flash.utils.Dictionary;

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;

	import flash.system.Capabilities;

	import flash.notifications.NotificationStyle;
	import flash.notifications.RemoteNotifier;
	import flash.notifications.RemoteNotifierSubscribeOptions;

	public class Teak extends EventDispatcher
	{
		public function Teak()
		{
			if(_instance) throw new Error("Use 'Teak.instance' instead of instantiating a new Teak object.");

			_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if(!_context) throw new Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
			if(_isAndroid() && _context.call("getInitializationErrors") !== null) throw new Error(_context.call("getInitializationErrors") as String);
			_context.addEventListener(StatusEvent.STATUS, onStatus);
			_deepLinks = new Dictionary();
			_instance = this;
		}

		public static function get instance():Teak
		{
			return _instance ? _instance : new Teak();
		}

		public function get version():Object
		{
			if(useNativeExtension())
			{
				return JSON.parse(_context.call("getVersion") as String);
			}
			else
			{
				return { adobeAir: "EDITOR" };
			}
		}

		public function registerForNotifications():void
		{
			var preferredStyles:Vector.<String> = new Vector.<String>();
			var subscribeOptions:RemoteNotifierSubscribeOptions = new RemoteNotifierSubscribeOptions();
			var remoteNot:RemoteNotifier = new RemoteNotifier();

			preferredStyles.push(NotificationStyle.ALERT, NotificationStyle.BADGE, NotificationStyle.SOUND);
			subscribeOptions.notificationStyles = preferredStyles;

			remoteNot.subscribe(subscribeOptions);
		}

		public function registerRoute(route:String, name:String, description:String, callback:Function):void
		{
			_deepLinks[route] = callback;

			if(useNativeExtension())
			{
				_context.call("registerRoute", route, name, description);
			}
			else
			{
				trace("[Teak] Registering route: " + route);
			}
		}

		public function identifyUser(userIdentifier:String):void
		{
			if(useNativeExtension())
			{
				_context.call("identifyUser", userIdentifier);
			}
			else
			{
				trace("[Teak] Identifying user: " + userIdentifier);
			}
		}

		public function scheduleNotification(creativeId:String, defaultMessage:String, delayInSeconds:Number):void
		{
			if(useNativeExtension())
			{
				_context.call("scheduleNotification", creativeId, defaultMessage, delayInSeconds);
			}
			else
			{
				trace("[Teak] Scheduling notification (" + creativeId + ") \"" + defaultMessage + "\" for " + delayInSeconds + " from now.");

				var e:TeakEvent = new TeakEvent(TeakEvent.NOTIFICATION_SCHEDULED, "DEBUG-SCHEDULE-ID");
				this.dispatchEvent(e);
			}
		}

		public function cancelNotification(scheduleId:String):void
		{
			if(useNativeExtension())
			{
				_context.call("cancelNotification", scheduleId);
			}
			else
			{
				trace("[Teak] Canceling notification: " + scheduleId);

				var e:TeakEvent = new TeakEvent(TeakEvent.NOTIFICATION_CANCELED, scheduleId);
				this.dispatchEvent(e);
			}
		}

		public function cancelAllNotifications():void
		{
			if(useNativeExtension())
			{
				_context.call("cancelAllNotifications");
			}
			else
			{
				trace("[Teak] Canceling all notifications.");

				var e:TeakEvent = new TeakEvent(TeakEvent.NOTIFICATION_CANCEL_ALL);
				this.dispatchEvent(e);
			}
		}

		public function setNumericAttribute(key:String, value:Number):void
		{
			if(useNativeExtension())
			{
				_context.call("setNumericAttribute", key, value);
			}
			else
			{
				trace("[Teak] setNumericAttribute: " + key + ", " + value);
			}
		}

		public function setStringAttribute(key:String, value:String):void
		{
			if(useNativeExtension())
			{
				_context.call("setStringAttribute", key, value);
			}
			else
			{
				trace("[Teak] setStringAttribute: " + key + ", " + value);
			}
		}

		public function openSettingsAppToThisAppsSettings():Boolean
		{
			if(useNativeExtension())
			{
				return _context.call("openSettingsAppToThisAppsSettings");
			}
			else
			{
				trace("[Teak] openSettingsAppToThisAppsSettings");
				return false;
			}
		}

		private function onStatus(event:StatusEvent):void
		{
			var e:TeakEvent;
			var eventData:Object;
			switch(event.code)
			{
				case "LAUNCHED_FROM_NOTIFICATION": {
						e = new TeakEvent(TeakEvent.LAUNCHED_FROM_NOTIFICATION, event.level);
					}
					break;
				case "NOTIFICATION_SCHEDULED": {
						eventData = JSON.parse(event.level);
						e = new TeakEvent(TeakEvent.NOTIFICATION_SCHEDULED, eventData.data, eventData.status);
					}
					break;
				case "NOTIFICATION_CANCELED": {
						eventData = JSON.parse(event.level);
						e = new TeakEvent(TeakEvent.NOTIFICATION_CANCELED, eventData.data, eventData.status);
					}
					break;
				case "NOTIFICATION_CANCEL_ALL": {
						eventData = JSON.parse(event.level);
						e = new TeakEvent(TeakEvent.NOTIFICATION_CANCEL_ALL, JSON.stringify(eventData.data), eventData.status);
					}
					break;
				case "DEEP_LINK": {
						eventData = JSON.parse(event.level);
						if(_deepLinks[eventData["route"]] !== undefined)
						{
							try
							{
								_deepLinks[eventData["route"]](eventData["parameters"]);
							}
							catch(error:Error)
							{
								log("Error calling function for route " + eventData["route"] + ": " + error);
							}
						}
						else
						{
							log("Unable to find function for route: " + eventData["route"]);
						}
					}
					break;
				case "ON_REWARD": {
						e = new TeakEvent(TeakEvent.ON_REWARD, event.level);
					}
					break;
				default:
					break;
			}
			if(e)
			{
				this.dispatchEvent(e);
			}
		}

		private function useNativeExtension():Boolean
		{
			return _isIOS() || _isAndroid();
		}

		private static function _isIOS():Boolean {
			return Capabilities.manufacturer.indexOf("iOS") > -1;
		}

		private static function _isAndroid():Boolean {
			return Capabilities.manufacturer.indexOf("Android") > -1;
		}

		public function log(message:String):void
		{
			if(useNativeExtension())
			{
				_context.call("_log", message);
			}
			else
			{
				trace(message);
			}
		}

		private static var _instance:Teak;
		private static const EXTENSION_ID:String = "io.teak.sdk.Teak";

		private var _context:ExtensionContext;
		private var _deepLinks:Dictionary;
	}
}
