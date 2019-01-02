package io.teak.sdk
{
	import flash.events.Event;
	
	public class TeakEvent extends Event
	{
		public static const LAUNCHED_FROM_NOTIFICATION:String = "launchedFromNotification";
		public static const NOTIFICATION_SCHEDULED:String = "notificationScheduled";
		public static const LONG_DISTANCE_NOTIFICATION_SCHEDULED:String = "longDistanceNotificationScheduled";
		public static const NOTIFICATION_CANCELED:String = "notificationCanceled";
		public static const NOTIFICATION_CANCEL_ALL:String = "notificationCancelAll";
		public static const ON_REWARD:String = "onReward";

		public var data:String;
		public var status:String;

		public function TeakEvent(type:String, data:String = null, status:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			this.status = status;
			super(type, bubbles, cancelable);
		}
	}
}
