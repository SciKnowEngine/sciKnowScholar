package edu.isi.bmkeg.lapdftextModule.controller
{	
	
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	
	import edu.isi.bmkeg.digitalLibrary.events.GenerateRuleFileFromLapdfEvent;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class GenerateRuleFileFromLapdfCommand extends Command
	{
	
		[Inject]
		public var event:GenerateRuleFileFromLapdfEvent;

		[Inject]
		public var service:IExtendedDigitalLibraryService;
						
		override public function execute():void
		{
			this.service.generateRuleFileFromLapdf(event.articleId);
		}
		
	}
	
}