package edu.isi.bmkeg.digitalLibrary.events
{
	import edu.isi.bmkeg.ftd.model.FTDFragmentBlock;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.rpc.events.FaultEvent;
	
	public class ChangeFragmentCodeEvent extends Event 
	{
		
		public static const ADD_FRAGMENT_CODE:String = "addFragmentCode";
		public static const REMOVE_FRAGMENT_CODE:String = "removeFragmentCode";
		
		public var addRemove:String;
		public var newFrgOrder:String;
		public var newBlkOrder:Number;
		public var block:FTDFragmentBlock;
		
		public function ChangeFragmentCodeEvent(addRemove:String,
												block:FTDFragmentBlock,
												newFrgOrder:String,
												newBlkOrder:Number,			
												bubbles:Boolean=false, 
												cancelable:Boolean=false ) {
			this.newFrgOrder = newFrgOrder;
			this.newBlkOrder = newBlkOrder;
			this.addRemove = addRemove;
			this.block = block;
			super(addRemove, bubbles, cancelable);
		}
		
		override public function clone(): Event {

			return new ChangeFragmentCodeEvent(addRemove, block, 
				newFrgOrder, newBlkOrder, bubbles, cancelable);
		
		}
		
	}
	
}
