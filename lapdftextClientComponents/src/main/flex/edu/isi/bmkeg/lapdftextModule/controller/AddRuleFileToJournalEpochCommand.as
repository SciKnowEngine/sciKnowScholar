package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.JournalEpoch_qo;
	import edu.isi.bmkeg.digitalLibrary.services.IExtendedDigitalLibraryService;
	import edu.isi.bmkeg.digitalLibrary.rl.events.ListJournalEpochEvent;
	import edu.isi.bmkeg.digitalLibrary.events.AddRuleFileToJournalEpochEvent;
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Command;
	
	public class AddRuleFileToJournalEpochCommand extends Command
	{
		
		[Inject]
		public var event:AddRuleFileToJournalEpochEvent;
		
		[Inject]
		public var service:IExtendedDigitalLibraryService;
	
		override public function execute():void
		{						
			this.service.addRuleFileToJournalEpoch(
				event.ruleFileId, event.epochId,
				event.epochJournal, event.epochStart, event.epochEnd
			);
		}
		
	}
	
}