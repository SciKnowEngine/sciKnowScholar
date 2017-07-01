package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.digitalLibrary.model.citations.*;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.digitalLibrary.rl.services.IDigitalLibraryService;
	import edu.isi.bmkeg.ftd.model.FTD;
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class ListArticleCitationPagedCommand extends Command
	{
	
		[Inject]
		public var event:ListArticleCitationPagedEvent;

		[Inject]
		public var model:LapdftextModel;
		
		[Inject]
		public var service:IDigitalLibraryService;
				
		override public function execute():void
		{
			model.queryLiteratureCitation = event.object;	
			
			// ORDER BY JOURNAL AND BY VOLUME
			if( event.object.journal == null ) {
				event.object.journal = new Journal_qo()
			}
			
			if( event.object.journal.abbr != null) {
				event.object.journal.abbr += "<vpdmf-sort-0>"
			} else {
				event.object.journal.abbr = "<vpdmf-sort-0>"				
			}

			if( event.object.volValue != null) {
				event.object.volValue += "<vpdmf-sort-1>"
			} else {
				event.object.volValue = "<vpdmf-sort-1>"
			}


			service.listArticleCitationPaged(event.object, event.offset, event.cnt);
			
		}
		
	}
	
}