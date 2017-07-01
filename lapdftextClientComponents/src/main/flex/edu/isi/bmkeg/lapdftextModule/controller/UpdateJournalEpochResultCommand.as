package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.digitalLibrary.model.citations.*;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.*;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateJournalEpochResultCommand extends Command
	{
		
		[Inject]
		public var event:UpdateJournalEpochResultEvent;
		
		[Inject]
		public var model:LapdftextModel;
		
		override public function execute():void
		{	
			this.dispatch(new FindJournalEpochByIdEvent(event.id));
			this.dispatch(new ListJournalEpochEvent(new JournalEpoch_qo()));				
		}
		
	}
	
}