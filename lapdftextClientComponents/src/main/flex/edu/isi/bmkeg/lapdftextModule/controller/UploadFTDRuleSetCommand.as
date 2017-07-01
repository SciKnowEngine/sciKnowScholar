package edu.isi.bmkeg.lapdftextModule.controller
{
	import org.robotlegs.mvcs.Command;
	
	import edu.isi.bmkeg.ftd.services.IExtendedFtdService;
	import edu.isi.bmkeg.ftd.model.*;
	import edu.isi.bmkeg.ftd.events.*;
	
	import flash.events.Event;
	
	public class UploadFTDRuleSetCommand extends Command
	{
		
		[Inject]
		public var event:UploadFTDRuleSetEvent;
		
		[Inject]
		public var service:IExtendedFtdService;
		
		override public function execute():void
		{
			service.uploadFtdRuleSet(event.data, event.ftdRules);
		}
		
	}
	
}