package edu.isi.bmkeg.ftd.events
{

	import edu.isi.bmkeg.ftd.model.FTDRuleSet;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.Button;

	public class RetrieveFTDRuleSetDataEvent extends Event {

		public static const RETRIEVE_FTD_RULE_SET_DATA:String = "retrieveFTDRuleSetData";

		public var id:Number;
		
		public function RetrieveFTDRuleSetDataEvent(id:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(RetrieveFTDRuleSetDataEvent.RETRIEVE_FTD_RULE_SET_DATA);
			this.id = id;
		}

		override public function clone() : Event
		{
			return new RetrieveFTDRuleSetDataEvent(id, bubbles, cancelable);
		}

	}
}
