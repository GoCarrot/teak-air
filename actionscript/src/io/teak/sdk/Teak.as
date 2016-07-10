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

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;

	import flash.system.Capabilities;

	public class Teak extends EventDispatcher
	{
		public function Teak()
		{
			if(_instance) throw new Error("Use 'Teak.instance' instead of instantiating a new Teak object.");

			_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if(!_context) throw new Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
			_context.addEventListener(StatusEvent.STATUS, onStatus);
			_instance = this;
		}

		public static function get instance():Teak
		{
			return _instance ? _instance : new Teak();
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

		private function onStatus(event:StatusEvent):void
		{
			var e:TeakEvent;
			switch(event.code)
			{
				case "LAUNCHED_FROM_NOTIFICATION":
					e = new TeakEvent(TeakEvent.LAUNCHED_FROM_NOTIFICATION, event.level);
					break;
				case "NOTIFICATION_SCHEDULED":
					e = new TeakEvent(TeakEvent.NOTIFICATION_SCHEDULED, event.level);
					break;
				case "NOTIFICATION_CANCELED":
					e = new TeakEvent(TeakEvent.NOTIFICATION_CANCELED, event.level);
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
			return Capabilities.manufacturer.indexOf("iOS") > -1 ||
					Capabilities.manufacturer.indexOf("Android") > -1;
		}

		private function log(message:String):void
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
		private var _versionNumber:String;
	}
}
