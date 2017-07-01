package edu.isi.bmkeg.lapdftextModule.controller
{	
	
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	
	import edu.isi.bmkeg.digitalLibrary.events.GenerateRuleFileFromLapdfResultEvent;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class GenerateRuleFileFromLapdfResultCommand extends Command
	{
	
		[Inject]
		public var event:GenerateRuleFileFromLapdfResultEvent;

		[Inject]
		public var model:LapdftextModel;
		
		override public function execute():void
		{
			model.ruleSetCsv = event.csv;
		}
		
	}
	
}