package edu.isi.bmkeg.pagedList.events
{
	import flash.events.Event;
	
	public class PagedListRetrievePageEvent extends Event
	{
		public static const PAGEDLIST_RETRIEVE_PAGE:String = "PagedListRetrievePageEvent";

		/**
		 * selected Article or null if none is selected
		 */
		public var listId:String;
		public var offset:int;
		public var count:int;
		
		public function PagedListRetrievePageEvent(offset:int, 
												   count:int,
												   listId:String=null,
												   bubbles:Boolean=false, 
												   cancelable:Boolean=false) {
			super(PAGEDLIST_RETRIEVE_PAGE + listId, bubbles, cancelable);
			this.listId = listId;
			this.offset = offset;
			this.count = count;
		}

		override public function clone():Event
		{
			return new PagedListRetrievePageEvent(offset, count, listId, bubbles, cancelable)
		}

	}
}