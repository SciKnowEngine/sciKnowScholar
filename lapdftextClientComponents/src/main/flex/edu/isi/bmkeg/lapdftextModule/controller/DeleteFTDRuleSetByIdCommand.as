package edu.isi.bmkeg.lapdftextModule.controller
{
	import org.robotlegs.mvcs.Command;
	
	import edu.isi.bmkeg.ftd.rl.services.IFtdService;
	import edu.isi.bmkeg.ftd.model.*;
	import edu.isi.bmkeg.ftd.rl.events.*;
	
	import flash.events.Event;
	
	public class DeleteFTDRuleSetByIdCommand extends Command
	{
		
		[Inject]
		public var event:DeleteFTDRuleSetByIdEvent;
		
		[Inject]
		public var service:IFtdService;
		
		override public function execute():void
		{
			service.deleteFTDRuleSetById(event.id);
		}
		
	}
	
}