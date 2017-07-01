package edu.isi.bmkeg.lapdftextModule.view
{
	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.model.citations.*;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.ftd.events.*;
	import edu.isi.bmkeg.ftd.model.*;
	import edu.isi.bmkeg.ftd.model.qo.*;
	import edu.isi.bmkeg.ftd.rl.events.*;
	import edu.isi.bmkeg.lapdftextModule.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.*;
	import edu.isi.bmkeg.lapdftextModule.view.forms.*;
	import edu.isi.bmkeg.utils.updownload.*;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import flash.net.FileReference;
	
	import mx.managers.PopUpManager;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class JournalEpochControlMediator_xx extends Mediator
	{
		[Inject]
		public var view:JournalEpochControl;
		
		[Inject]
		public var model:LapdftextModel;
		
		override public function onRegister():void
		{
									
			// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			// list the journal epochs. 
			addViewListener(
				ListExtendedJournalEpochsEvent.LIST_EXTENDED_JOURNAL_EPOCHS,
				dispatch);

			addContextListener(
				ListExtendedJournalEpochsResultEvent.LIST_EXTENDED_JOURNAL_EPOCHS_RESULT, 
				listCorpusResultHandler);

			addViewListener(
				RunRulesOverAllEpochsEvent.RUN_RULES_OVER_ALL_EPOCHS, 
				dispatch);
			
			// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			// list the Rule files. 
			addViewListener(
				ListFTDRuleSetEvent.LIST_FTDRULESET,
				dispatch);

			addContextListener(
				ListFTDRuleSetResultEvent.LIST_FTDRULESET_RESULT, 
				listRuleSetHandler);

			addViewListener(
				UploadCompleteEvent.UPLOAD_COMPLETE,
				uploadFTDRuleFile);

			addViewListener(
				ClearUpdownloadEvent.CLEAR_UPDOWNLOAD,
				deleteFTDRuleFile);
			
			addViewListener(
				FindFTDRuleSetByIdEvent.FIND_FTDRULESET_BY_ID,
				dispatch);

			addContextListener(
				FindFTDRuleSetByIdResultEvent.FIND_FTDRULESETBY_ID_RESULT,
				findFTDRuleByIdResultHandler);

			
			// TOD: RESULT HANDLER
//			addContextListener(ListExtendedJournalEpochsResultEvent.LIST_EXTENDED_JOURNAL_EPOCHS_RESULT, 
//				listCorpusResultHandler);
			
			// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			// Popups for editing Journal Epochs. 
			addViewListener(ActivateJournalEpochPopupEvent.ACTIVATE_JOURNAL_EPOCH_POPUP, 
				activateCorpusPopup);

			addViewListener(AddRuleFileToJournalEpochEvent.ADD_RULE_FILE_TO_JOURNAL_EPOCH, 
				dispatch)			
			
			addViewListener(RunRuleSetOnJournalEpochEvent.RUN_RULE_SET_ON_JOURNAL_EPOCH, 
				dispatch)	
			
			// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			// Popups for Listing Articles. 
			addViewListener(ListArticleCitationPagedEvent.LIST_ARTICLECITATION_PAGED, 
				dispatch);
			
			// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			// On loading this control, we first list all the corpora on the server
			dispatch(new ListExtendedJournalEpochsEvent());
			dispatch(new ListFTDRuleSetEvent(new FTDRuleSet_qo()));			
			
		}

		public function listCorpusResultHandler(event:ListExtendedJournalEpochsResultEvent):void {
			view.epochList = model.epochList;
			//view.corpusCombo.selectedIndex = 0;
		}
		
		public function listRuleSetHandler(event:ListFTDRuleSetResultEvent):void {
			view.ruleFiles = model.ruleSetList;
			//view.corpusCombo.selectedIndex = 0;
		}
		
		public function findFTDRuleByIdResultHandler(event:FindFTDRuleSetByIdResultEvent):void {
			view.updownButtons.fileName = event.object.fileName;
			
			// Note the data for the rule files stay on the server once it's uploaded.
			//view.updownButtons.fileData = event.object.excelFile;
			
			view.updownButtons.fileNameBox.styleName = 'active';
			view.updownButtons.clearButton.enabled = true;
			
		}
		
		public function dispatchFindCorpusById(event:FindCorpusByIdEvent):void {
			
			model.epoch = new JournalEpoch();
			model.epoch.vpdmfId = event.id;

			var ac:ArticleCitation_qo = new ArticleCitation_qo();
			var c:Corpus_qo = new Corpus_qo();			
			ac.corpora.addItem(c);
			
			c.vpdmfId = String(model.epoch.vpdmfId);
				
			this.dispatch(new ListArticleCitationPagedEvent(
				ac, 0, model.listPageSize));
			
			this.dispatch( event );
			
		}
		
		private function activateCorpusPopup(e:ActivateJournalEpochPopupEvent):void {

			var popup:CorpusPopup = PopUpManager.createPopUp(this.view, CorpusPopup, true) as CorpusPopup;
			PopUpManager.centerPopUp(popup);

			mediatorMap.createMediator( popup );
				
			popup.vpdmfId = e.corpus.vpdmfId;
			
		}
		
		private function handleLoadedTargetCorpus(event:FindJournalEpochByIdResultEvent):void {

			this.view.epoch = event.object;
	
			this.reloadArticleList();

		}
		
		private function selectCorpus(event:SelectCorpus):void {
						
			for each( var c:Object in model.epochList ) {
				if( c.vpdmfId == event.corpusId ) {
				//	view.corpusCombo.selectedItem = c;
					break;
				}
			}
					
		}

		private function addArticleCitationToCorpusResult(
			event:AddArticleCitationToCorpusResultEvent):void {
			
			this.reloadArticleList();
			
		}
		
		private function removeArticleCitationFromCorpusResult(
			event:RemoveArticleCitationFromCorpusResultEvent):void {
				
			this.reloadArticleList();
				
		}

		private function fullyDeleteArticleResult(
			event:FullyDeleteArticleResultEvent):void {
			
			this.reloadArticleList();
			
		}
		
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Reset everything
		//
		public function clearCorpusHandler(event:ClearCorpusEvent):void {

			view.currentState = "empty";
			//view.corpusCombo.selectedIndex = -1;
			dispatch(new ListCorpusEvent(new Corpus_qo()));
			
		}
		
		private function reloadArticleList():void {
			
			var acQ:ArticleCitation_qo = new ArticleCitation_qo();
			
			if( model.epoch != null ) {
				var corpQ:Corpus_qo = new Corpus_qo();
				acQ.corpora.addItem(corpQ);
				
				corpQ.vpdmfId = model.epoch.vpdmfId + "";
			}
			
			this.dispatch( new ListArticleCitationPagedEvent(acQ, 0, 300) );		
		}

		private function deleteFTDRuleFile(clearUpDownloadEvent:ClearUpdownloadEvent):void {
			
			var rs:FTDRuleSet = model.ruleSet;
			
			if( rs == null ) {	
				return;
			}
			
			var ev2:DeleteFTDRuleSetByIdEvent = new DeleteFTDRuleSetByIdEvent(rs.vpdmfId);
			this.dispatch(ev2);
			
		}

		private function uploadFTDRuleFile(uploadCompleteEvent:UploadCompleteEvent):void {
			
			var ruleFile:FileReference = uploadCompleteEvent.file;
			
			var newRs:FTDRuleSet = new FTDRuleSet();
			newRs.fileName = ruleFile.name;
			var s:String = ruleFile.name;
			s = s.substring(s.length-8, s.length);
			var rsName:String = ruleFile.name.substr(0,ruleFile.name.length-4);
			newRs.rsName = rsName;
			
			var event:UploadFTDRuleSetEvent = new UploadFTDRuleSetEvent(ruleFile.data, newRs);
			
			this.dispatch( event );
			
		}

		
	}
	
}