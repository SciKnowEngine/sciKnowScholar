package edu.isi.bmkeg.lapdftextModule.controller
{	

	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;

	import org.robotlegs.mvcs.Command;
	
	public class RetrieveFTDRuleSetForArticleCitationCommand extends Command {
		
		[Inject]
		public var event:RetrieveFTDRuleSetForArticleCitationEvent;
		
		[Inject]
		public var service:IExtendedDigitalLibraryService;

		override public function execute():void {
			service.retrieveFTDRuleSetForArticleCitation( event.articleId );	
		}
		
	}
	
}