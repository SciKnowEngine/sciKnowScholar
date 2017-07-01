package edu.isi.bmkeg.lapdftextModule.events
{
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.rpc.events.FaultEvent;
	
	public class ChangeLapdftexBlockViewEvent extends Event 
	{
		
		public static const CHANGE_LAPDFTEXTBLOCK_VIEW:String = "changeLapdftexBlockView";
		
		public var pgOrBlocks:String;
		
		public function ChangeLapdftexBlockViewEvent( pgOrBlocks:String,
				bubbles:Boolean=false, cancelable:Boolean=false )
		{
			this.pgOrBlocks = pgOrBlocks;
			super(CHANGE_LAPDFTEXTBLOCK_VIEW, bubbles, cancelable);
		}
		
		override public function clone() : Event
		{
			return new ChangeLapdftexBlockViewEvent(pgOrBlocks, bubbles, cancelable);
		}
		
	}
	
}
