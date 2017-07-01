package edu.isi.bmkeg.lapdftextModule.controller
{	
	import org.robotlegs.mvcs.Command;
	
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	import edu.isi.bmkeg.digitalLibrary.events.*;

	import flash.events.Event;
	
	public class LoadPmcXmlCommand extends Command
	{
	
		[Inject]
		public var event:LoadPmcXmlEvent;
		
		[Inject]
		public var service:IExtendedDigitalLibraryService;
				
		override public function execute():void
		{
			service.loadPmcXml(event.vpdmfId);			
		}
		
	}
	
}