package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class InsertJournalEpochResultCommand extends Command
	{
		
		[Inject]
		public var event:InsertJournalEpochResultEvent;
		
		[Inject]
		public var model:LapdftextModel;
		
		override public function execute():void
		{	
			this.dispatch(new FindJournalEpochByIdEvent(event.id));
			this.dispatch(new ListJournalEpochEvent(new JournalEpoch_qo()));				
		}
		
	}
	
}