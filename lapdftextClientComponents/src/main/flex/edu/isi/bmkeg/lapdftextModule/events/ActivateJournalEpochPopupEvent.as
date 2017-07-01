package edu.isi.bmkeg.lapdftextModule.events
{
	
	import edu.isi.bmkeg.digitalLibrary.model.citations.JournalEpoch;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.rpc.events.FaultEvent;
	
	public class ActivateJournalEpochPopupEvent extends Event 
	{
		
		public static const ACTIVATE_JOURNAL_EPOCH_POPUP:String = "activateJournalEpochPopup";
		
		public var corpus:JournalEpoch;
		
		public function ActivateJournalEpochPopupEvent(corpus:JournalEpoch = null)
		{
			this.corpus = corpus;
				
			super(ACTIVATE_JOURNAL_EPOCH_POPUP);
		}
		
		override public function clone() : Event
		{
			return new ActivateJournalEpochPopupEvent(corpus);
		}
		
	}
	
}
