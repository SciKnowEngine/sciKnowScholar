package edu.isi.bmkeg.pagedList.events
{
	import flash.events.Event;
	
	public class CountPagedListLengthEvent extends Event
	{
		public static const COUNT_PAGED_LIST_LENGTH:String = "CountPagedListLengthEvent";

		public var listId:String;
		
		public function CountPagedListLengthEvent(listId:String=null, 
												  bubbles:Boolean=false, 
												  cancelable:Boolean=false)
		{
			this.listId = listId;
			super(COUNT_PAGED_LIST_LENGTH + listId, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new CountPagedListLengthEvent(listId, bubbles, cancelable)
		}

	}
}