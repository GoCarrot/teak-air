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
	public final class TeakNotificationState
	{
		public static const UnableToDetermine:TeakNotificationState = new TeakNotificationState(-1);
		public static const Enabled:TeakNotificationState = new TeakNotificationState(0);
		public static const Disabled:TeakNotificationState = new TeakNotificationState(1);
		public static const Provisional:TeakNotificationState = new TeakNotificationState(2);
		public static const NotRequested:TeakNotificationState = new TeakNotificationState(3);

		private var intValue:int;
		public function TeakNotificationState(i:int)
		{
			this.intValue = i;
		}

		public function equals(toCompare:TeakNotificationState):Boolean
		{
			return this.intValue === toCompare.intValue;
		}
	}
}
