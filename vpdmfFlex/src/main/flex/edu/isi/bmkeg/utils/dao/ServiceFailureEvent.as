package edu.isi.bmkeg.utils.dao
{
	import flash.events.Event;
	
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	
	public class ServiceFailureEvent extends Event
	{
		
		public static const FAIL:String = "ServiceFailureEvent";
		
		public var faultEvent:FaultEvent;

		public function ServiceFailureEvent(faultEvent:FaultEvent, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(FAIL, bubbles, cancelable);
			this.faultEvent = faultEvent;
		}
		
		override public function clone():Event
		{
			var event:ServiceFailureEvent = new ServiceFailureEvent(faultEvent, bubbles, cancelable);			
			return event;
		}

	}
}