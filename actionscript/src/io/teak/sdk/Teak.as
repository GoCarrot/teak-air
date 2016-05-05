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

	public class Teak
	{
		public function Teak()
		{
			if(_instance) throw new Error("Use 'Teak.instance' instead of instantiating a new Teak object.");

			_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if(!_context) throw new Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
			_instance = this;
		}

		public static function get instance():Teak
		{
			return _instance ? _instance : new Teak();
		}

		public function init(appId:String, apiKey:String):void
		{
			_context.call("_init", appId, apiKey);
		}

		public function identifyUser(userIdentifier:String):void
		{
			_context.call("identifyUser", userIdentifier);
		}

		private static var _instance:Teak;
		private static const EXTENSION_ID : String = "io.teak.sdk.Teak";

		private var _context : ExtensionContext;
	}
}
