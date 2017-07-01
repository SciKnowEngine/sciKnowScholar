package edu.isi.bmkeg.pagedList.events
{
	
	import flash.events.Event;
	
	public class PagedListSelectionChangedEvent extends Event
	{
		public static const CHANGED:String = "PagedListSelectionChangedEvent";

		/**
		 * selected Article or null if none is selected
		 */
		public var listId:String;
		public var selectedIndex:int;
		
		public function PagedListSelectionChangedEvent(selectedIndex:int,
													   listId:String=null,
													   bubbles:Boolean=false, 
													   cancelable:Boolean=false)
		{
			super(CHANGED+listId, bubbles, cancelable);
			this.selectedIndex = selectedIndex;
			this.listId = listId;
		}

		override public function clone():Event
		{
			return new PagedListSelectionChangedEvent(selectedIndex, listId, bubbles, cancelable)
		}

	}
}