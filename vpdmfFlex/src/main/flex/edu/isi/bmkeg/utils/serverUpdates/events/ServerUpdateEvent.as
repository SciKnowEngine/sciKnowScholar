package edu.isi.bmkeg.utils.serverUpdates.events
{
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.rpc.events.FaultEvent;
	
	public class ServerUpdateEvent extends Event 
	{
		
		public static const SERVER_UPDATE:String = "serverUpdate";
		
		public var message:String;
		
		public function ServerUpdateEvent(message:String,
												 bubbles:Boolean=false, 
												 cancelable:Boolean=false) {
			this.message = message;
			
			super(SERVER_UPDATE, bubbles, cancelable);
		}
		
		override public function clone() : Event
		{
			return new ServerUpdateEvent(message, bubbles, cancelable);
		}
		
	}
	
}
