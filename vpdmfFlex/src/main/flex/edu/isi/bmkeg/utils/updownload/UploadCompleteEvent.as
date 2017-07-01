package edu.isi.bmkeg.utils.updownload
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	public class UploadCompleteEvent extends Event
	{
		public static const UPLOAD_COMPLETE:String = "uploadCompleteEvent";

		public var file:FileReference;
		
		public function UploadCompleteEvent(file:FileReference, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(UPLOAD_COMPLETE, bubbles, cancelable);
			this.file = file;
		}

		override public function clone():Event
		{
			return new UploadCompleteEvent(file, bubbles, cancelable)
		}

	}
}