package edu.isi.bmkeg.utils.updownload
{
	import flash.events.Event;
	
	public class ClearUpdownloadEvent extends Event
	{
		public static const CLEAR_UPDOWNLOAD:String = "clearUpdownloadEvent";
 		
		public function ClearUpdownloadEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(CLEAR_UPDOWNLOAD, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new ClearUpdownloadEvent(bubbles, cancelable)
		}

	}
}