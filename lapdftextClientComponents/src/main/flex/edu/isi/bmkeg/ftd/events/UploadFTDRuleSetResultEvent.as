package edu.isi.bmkeg.ftd.events
{
	
	import edu.isi.bmkeg.ftd.model.FTDRuleSet;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.Button;
	
	public class UploadFTDRuleSetResultEvent extends Event {
		
		public static const UPLOAD_FTD_RULE_SET_RESULT:String = "uploadFtdRuleSetResult";
				
		public function UploadFTDRuleSetResultEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(UploadFTDRuleSetResultEvent.UPLOAD_FTD_RULE_SET_RESULT, bubbles, cancelable);
		}
		
		override public function clone() : Event
		{
			return new UploadFTDRuleSetResultEvent(bubbles, cancelable);
		}
		
	}
}
