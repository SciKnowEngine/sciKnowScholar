package edu.isi.bmkeg.tabbedWindows
{
//	import edu.isi.bmkeg.neuart.atlasbrowser.views.ViewerWindow;
	
	import flash.events.Event;
	
	import mx.core.Container;

	public class TabbedWindowEvent extends Event
	{
		
		public static const CLOSE_CLICK:String = "closeClick";
		public static const SPLIT_VERTICALLY_CLICK:String = "splitVerticallyClick";
		public static const SPLIT_HORIZONTALLY_CLICK:String = "splitHorizontallyClick";

		public var tabbedWindow:Container;
		
		public function TabbedWindowEvent(type:String, window:Container)
		{
			super(type);
			this.tabbedWindow = window;
		}
		
		override public function clone():Event
		{
			return new TabbedWindowEvent(type,tabbedWindow);
		}

	}
}