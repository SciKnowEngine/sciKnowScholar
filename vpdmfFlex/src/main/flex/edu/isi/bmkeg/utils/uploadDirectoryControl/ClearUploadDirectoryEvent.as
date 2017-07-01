package edu.isi.bmkeg.utils.uploadDirectoryControl
{
	import flash.events.Event;
	
	public class ClearUploadDirectoryEvent extends Event
	{
		public static const CLEAR_UPLOAD_DIRECTORY:String = "clearUploadDirectoryEvent";
 		
		public function ClearUploadDirectoryEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(CLEAR_UPLOAD_DIRECTORY, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new ClearUploadDirectoryEvent(bubbles, cancelable)
		}

	}
}