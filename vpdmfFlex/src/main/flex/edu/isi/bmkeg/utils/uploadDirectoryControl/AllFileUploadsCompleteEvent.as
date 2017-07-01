package edu.isi.bmkeg.utils.uploadDirectoryControl
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	public class AllFileUploadsCompleteEvent extends Event
	{
		public static const ALL_FILE_UPLOADS_COMPLETE:String = "allFileUploadsComplete";

		public var success:Boolean;
		
		public function AllFileUploadsCompleteEvent(success:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(ALL_FILE_UPLOADS_COMPLETE, bubbles, cancelable);
			this.success = success;
		}

		override public function clone():Event
		{
			return new AllFileUploadsCompleteEvent(success, bubbles, cancelable)
		}

	}
}