package edu.isi.bmkeg.lapdftextModule.controller
{	

	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;

	import org.robotlegs.mvcs.Command;
	
	public class RunRuleSetOnArticleCitationCommand extends Command {
		
		[Inject]
		public var event:RunRuleSetOnArticleCitationEvent;
		
		[Inject]
		public var service:IExtendedDigitalLibraryService;

		override public function execute():void {
			service.runRuleSetOnArticleCitation( event.ruleSetId, event.articleId );	
		}
		
	}
	
}