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
	import flash.events.Event;
	
	public class TeakEvent extends Event
	{
		public static const LAUNCHED_FROM_NOTIFICATION:String = "launchedFromNotification";
		public static const NOTIFICATION_SCHEDULED:String = "notificationScheduled";
		public static const NOTIFICATION_CANCELED:String = "notificationCanceled";

		public var data:String;

		public function TeakEvent(type:String, data:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}
