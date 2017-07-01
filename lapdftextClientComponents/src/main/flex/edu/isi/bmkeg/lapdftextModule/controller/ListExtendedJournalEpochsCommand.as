package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	import edu.isi.bmkeg.digitalLibrary.events.ListExtendedJournalEpochsEvent;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class ListExtendedJournalEpochsCommand extends Command
	{
	
		[Inject]
		public var event:ListExtendedJournalEpochsEvent;

		[Inject]
		public var model:LapdftextModel;
		
		[Inject]
		public var service:IExtendedDigitalLibraryService;
				
		override public function execute():void
		{	
			service.listExtendedJournalEpochs();
		}
		
	}
	
}