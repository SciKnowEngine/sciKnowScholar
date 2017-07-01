package edu.isi.bmkeg.lapdftextModule.controller
{
	import org.robotlegs.mvcs.Command;
	
	import edu.isi.bmkeg.pagedList.model.*;
	
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextPagedListModel;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	
	import flash.events.Event;
	
	public class CountArticleCitationResultCommand extends Command
	{
		
		[Inject]
		public var event:CountArticleCitationResultEvent;
		
		[Inject]
		public var model:LapdftextPagedListModel;
		
		override public function execute():void
		{
			model.pagedListLength = event.count;
		}
		
	}

}