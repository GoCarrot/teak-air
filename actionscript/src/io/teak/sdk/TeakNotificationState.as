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
