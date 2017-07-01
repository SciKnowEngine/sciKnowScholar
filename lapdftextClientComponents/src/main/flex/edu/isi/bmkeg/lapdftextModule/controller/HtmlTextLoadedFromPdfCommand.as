package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.pagedList.events.*;
	
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	
	import edu.isi.bmkeg.digitalLibrary.events.*;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
	
	public class HtmlTextLoadedFromPdfCommand extends Command
	{
	
		[Inject]
		public var event:HtmlTextLoadedFromPdfEvent;

		[Inject]
		public var model:LapdftextModel;
		
		override public function execute():void
		{
			model.pmcHtml = event.html;
		}
		
	}
	
}