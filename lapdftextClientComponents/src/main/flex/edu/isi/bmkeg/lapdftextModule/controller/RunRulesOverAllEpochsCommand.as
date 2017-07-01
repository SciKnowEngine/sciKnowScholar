package edu.isi.bmkeg.lapdftextModule.controller
{	

	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	import edu.isi.bmkeg.digitalLibraryModule.controller.FindArticleCitationByIdCommand;
	
	import org.robotlegs.mvcs.Command;
	
	public class RunRulesOverAllEpochsCommand extends Command {
		
		[Inject]
		public var event:RunRulesOverAllEpochsEvent;
		
		[Inject]
		public var service:IExtendedDigitalLibraryService;

		override public function execute():void {
			service.runRulesOverAllEpochs();
		}
		
	}
	
}