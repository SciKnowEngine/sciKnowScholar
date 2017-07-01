package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Command;
	
	public class AddRuleFileToJournalEpochResultCommand extends Command
	{
	
		[Inject]
		public var event:AddRuleFileToJournalEpochResultEvent;
		
		[Inject]
		public var model:LapdftextModel;
		
		override public function execute():void
		{						
			// refresh the controls that list the Journal Epochs
			this.dispatch( new ListExtendedJournalEpochsEvent() );
		}
		
	}
	
}