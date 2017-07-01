package edu.isi.bmkeg.ftd.events
{

	import edu.isi.bmkeg.ftd.model.FTDRuleSet;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.Button;

	public class RetrieveFTDRuleSetDataResultEvent extends Event {

		public static const RETRIEVE_FTD_RULE_SET_DATA_RESULT:String = "retrieveFtdRuleSetDataResult";

		public var data:ByteArray;
		
		public function RetrieveFTDRuleSetDataResultEvent(data:ByteArray,
												bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(RetrieveFTDRuleSetDataResultEvent.RETRIEVE_FTD_RULE_SET_DATA_RESULT);
			this.data = data;
		}

		override public function clone() : Event
		{
			return new RetrieveFTDRuleSetDataResultEvent(data, bubbles, cancelable);
		}

	}
}
