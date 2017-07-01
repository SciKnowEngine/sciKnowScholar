package edu.isi.bmkeg.ftd.events
{

	import edu.isi.bmkeg.ftd.model.FTDRuleSet;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.Button;

	public class UploadFTDRuleSetEvent extends Event {

		public static const UPLOAD_FTD_RULE_SET:String = "uploadFtdRuleSet";

		public var data:ByteArray;
		public var ftdRules:FTDRuleSet;
		
		public function UploadFTDRuleSetEvent(data:ByteArray, ftdRules:FTDRuleSet,
												bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(UploadFTDRuleSetEvent.UPLOAD_FTD_RULE_SET);
			this.data = data;
			this.ftdRules = ftdRules;			
		}

		override public function clone() : Event
		{
			return new UploadFTDRuleSetEvent(data, ftdRules, bubbles, cancelable);
		}

	}
}
