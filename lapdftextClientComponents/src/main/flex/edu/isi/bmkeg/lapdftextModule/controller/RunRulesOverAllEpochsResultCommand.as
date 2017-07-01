package edu.isi.bmkeg.lapdftextModule.controller
{	

	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	import edu.isi.bmkeg.digitalLibraryModule.controller.FindArticleCitationByIdCommand;
	
	import org.robotlegs.mvcs.Command;
	
	public class RunRulesOverAllEpochsResultCommand extends Command {
		
		[Inject]
		public var event:RunRulesOverAllEpochsResultEvent;
		
		override public function execute():void {
			
			// Don't really do anything for this command
			var i:int = 0;
			
		}
		
	}
	
}