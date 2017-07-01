package edu.isi.bmkeg.lapdftextModule.controller
{
	import edu.isi.bmkeg.digitalLibrary.rl.events.FindArticleCitationByIdResultEvent;
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.ftd.rl.events.*;
	import edu.isi.bmkeg.ftd.model.qo.*;

	import org.robotlegs.mvcs.Command;
	
	public class FindArticleCitationByIdResultCommand extends Command
	{
		[Inject]
		public var event:FindArticleCitationByIdResultEvent;
		
		[Inject]
		public var model:LapdftextModel;
		
		override public function execute():void {
			
			model.citation = event.object;
			
		}
		
	}
	
}