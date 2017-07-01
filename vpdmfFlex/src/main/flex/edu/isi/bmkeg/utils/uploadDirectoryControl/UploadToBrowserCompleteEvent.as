package edu.isi.bmkeg.utils.uploadDirectoryControl
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	public class UploadToBrowserCompleteEvent extends Event
	{
		public static const UPLOAD_TO_BROWSER_COMPLETE:String = "uploadToBrowserCompleteEvent";

		public var file:FileReference;
		
		public function UploadToBrowserCompleteEvent(file:FileReference, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(UPLOAD_TO_BROWSER_COMPLETE, bubbles, cancelable);
			this.file = file;
		}

		override public function clone():Event
		{
			return new UploadToBrowserCompleteEvent(file, bubbles, cancelable)
		}

	}
}