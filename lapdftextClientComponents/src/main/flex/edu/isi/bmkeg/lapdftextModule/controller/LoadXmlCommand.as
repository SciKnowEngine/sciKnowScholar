package edu.isi.bmkeg.lapdftextModule.controller
{	
	import org.robotlegs.mvcs.Command;
	
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	import edu.isi.bmkeg.digitalLibrary.events.*;

	import flash.events.Event;
	
	public class LoadXmlCommand extends Command
	{
	
		[Inject]
		public var event:LoadXmlEvent;
		
		[Inject]
		public var service:IExtendedDigitalLibraryService;
				
		override public function execute():void
		{
			service.loadXml(event.vpdmfId);			
		}
		
	}
	
}