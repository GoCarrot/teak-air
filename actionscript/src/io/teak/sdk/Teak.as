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

	public class Teak extends EventDispatcher
	{
		public function Teak()
		{
			if(_instance) throw new Error("Use 'Teak.instance' instead of instantiating a new Teak object.");

			_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if(!_context) throw new Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
			_context.addEventListener(StatusEvent.STATUS, onStatus);
			_instance = this;

			// Get version and output it
			var ext_dir:File = ExtensionContext.getExtensionDirectory(EXTENSION_ID);
			var ane_dir:File = ext_dir.resolvePath("META-INF/ANE/");
			var ext_stream:FileStream = new FileStream();
			ext_stream.open(ane_dir.resolvePath("extension.xml"), FileMode.READ);
			var ext_xml:XML = XML(ext_stream.readUTFBytes(ext_stream.bytesAvailable));
			ext_stream.close();
			var ns:Namespace = ext_xml.namespace();
			_versionNumber = ext_xml.ns::versionNumber.toString();

			_context.call("_log", "AIR SDK Version: " + _versionNumber);
		}

		public static function get instance():Teak
		{
			return _instance ? _instance : new Teak();
		}

		public function get version():String
		{
			return _versionNumber;
		}

		public function identifyUser(userIdentifier:String):void
		{
			_context.call("identifyUser", userIdentifier);
		}

		public function scheduleNotification(creativeId:String, defaultMessage:String, delayInSeconds:Number):void
		{
			_context.call("scheduleNotification", creativeId, defaultMessage, delayInSeconds);
		}

		public function cancelNotification(scheduleId:String):void
		{
			_context.call("cancelNotification", scheduleId);
		}

		private function onStatus(event:StatusEvent):void
		{
			trace(event);
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

		private static var _instance:Teak;
		private static const EXTENSION_ID:String = "io.teak.sdk.Teak";

		private var _context:ExtensionContext;
		private var _versionNumber:String;
	}
}
