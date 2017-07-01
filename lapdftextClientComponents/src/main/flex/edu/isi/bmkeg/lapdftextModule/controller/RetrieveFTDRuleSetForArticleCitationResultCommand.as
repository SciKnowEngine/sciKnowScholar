package edu.isi.bmkeg.lapdftextModule.controller
{	

	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;

	import org.robotlegs.mvcs.Command;
	
	public class RetrieveFTDRuleSetForArticleCitationResultCommand extends Command {
		
		[Inject]
		public var event:RetrieveFTDRuleSetForArticleCitationResultEvent;
		
		[Inject]
		public var model:LapdftextModel;

		override public function execute():void {
			model.ruleSet = event.ruleSet;	
		}
		
	}
	
}