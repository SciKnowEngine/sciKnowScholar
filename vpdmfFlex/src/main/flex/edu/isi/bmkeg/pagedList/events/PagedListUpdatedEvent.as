package edu.isi.bmkeg.pagedList.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class PagedListUpdatedEvent extends Event
	{
		public static const UPDATED:String = "InfiniteListUpdatedEvent";
		
		public var listId:String;
		
		public function PagedListUpdatedEvent(listId:String=null,
											  bubbles:Boolean=false, 
											  cancelable:Boolean=false)
		{
			super(UPDATED+listId, bubbles, cancelable);
			this.listId = listId;
		}

		override public function clone():Event
		{
			return new PagedListUpdatedEvent(listId, bubbles, cancelable)
		}

	}
}