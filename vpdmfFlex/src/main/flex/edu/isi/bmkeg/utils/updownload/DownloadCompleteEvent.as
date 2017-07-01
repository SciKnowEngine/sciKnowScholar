package edu.isi.bmkeg.utils.updownload
{
	import flash.events.Event;
	
	public class DownloadCompleteEvent extends Event
	{
		public static const DOWNLOAD_COMPLETE:String = "downloadCompleteEvent";
 		
		public function DownloadCompleteEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(DOWNLOAD_COMPLETE, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new DownloadCompleteEvent(bubbles, cancelable)
		}

	}
}