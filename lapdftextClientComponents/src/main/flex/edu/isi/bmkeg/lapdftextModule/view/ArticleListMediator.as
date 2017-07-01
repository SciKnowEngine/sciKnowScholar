package edu.isi.bmkeg.lapdftextModule.view
{
	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.model.citations.*;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.FindArticleCitationByIdEvent;
	import edu.isi.bmkeg.digitalLibraryModule.view.ArticleList;
	import edu.isi.bmkeg.lapdftextModule.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.*;
	import edu.isi.bmkeg.lapdftextModule.view.forms.*;
	import edu.isi.bmkeg.lapdftextModule.events.*;
	import edu.isi.bmkeg.pagedList.events.*;
	import edu.isi.bmkeg.pagedList.model.*;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import mx.collections.ArrayCollection;
	import mx.managers.PopUpManager;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ArticleListMediator extends Mediator
	{
		[Inject]
		public var view:ArticleList;
		
		[Inject]
		public var listModel:LapdftextPagedListModel;

		[Inject]
		public var model:LapdftextModel;
		
		override public function onRegister():void
		{
			
			addContextListener(PagedListUpdatedEvent.UPDATED + LapdftextPagedListModel.LIST_ID, 
				targetDocumentsListUpdatedHandler);
						
			//
			// SelectCorpus is an intermediate event thrown by the CorpusListPopup view.	
			//
			addContextListener(SelectCorpus.SELECT_CORPUS, 
				addArticlesToCorpus);

			addViewListener(RemoveArticleCitationFromCorpusEvent.REMOVE_ARTICLE_CITATION_FROM_CORPUS, 
				handleRemoveArticlesFromCorpus);
			
			addViewListener(FindArticleCitationByIdEvent.FIND_ARTICLECITATION_BY_ID, 
				dispatch);

			addViewListener(UploadPdfFileEvent.UPLOAD_PDF_FILE, uploadPdfFileEventHandler);

			listModel.pageSize = model.listPageSize;

			view.currentState = "noEdit";

			var qo:ArticleCitation_qo = new ArticleCitation_qo();
			var event:ListArticleCitationPagedEvent = new ListArticleCitationPagedEvent(qo,0,200);
			this.dispatch( event );
			
		}
		
		private function targetDocumentsListUpdatedHandler(event:PagedListUpdatedEvent):void
		{
			
			view.documentsList = listModel.pagedList;
			view.listLength = listModel.pagedListLength;
			
		}
		
		private function uploadPdfFileEventHandler(event:UploadPdfFileEvent):void
		{
			
			/*if( model.epoch != null ) {
				event.corpusName = model.epoch.name;
			}*/
			dispatch(event);
			
		}
		
		private function activateCorpusListPopup(e:ActivateCorpusListPopupEvent):void {
			
			var popup:CorpusListPopup = PopUpManager.createPopUp(this.view, CorpusListPopup, true) 
				as CorpusListPopup;
			PopUpManager.centerPopUp(popup);
			
			mediatorMap.createMediator( popup );
					
		}
		
		private function addArticlesToCorpus(event:SelectCorpus):void 
		{

			var selectedArticles:Vector.<Object> = view.targetDocumentListDataGrid.selectedItems;
			
			if( selectedArticles.length == 0 ) {
				return;
			}
			
			var ids:ArrayCollection = new ArrayCollection();
			for each( var a:Object in selectedArticles) {
				var n:Number = new Number(a.vpdmfId);
				ids.addItem( n );
			}

			dispatch(new AddArticleCitationToCorpusEvent(ids, event.corpusId));
			
		}
		
		private function handleRemoveArticlesFromCorpus(event:RemoveArticleCitationFromCorpusEvent):void 
		{
			
			var selectedArticles:Vector.<Object> = view.targetDocumentListDataGrid.selectedItems;
			
			if( selectedArticles == null || selectedArticles.length == 0 ) {
				return;
			}
			
			var ids:ArrayCollection = new ArrayCollection();
			for each( var a:Object in selectedArticles) {
				var n:Number = new Number(a.vpdmfId);
				ids.addItem( n );
			}
			
			event.articleIds = ids;
			event.corpusId = model.epoch.vpdmfId;
			
			dispatch( event );
			
		}
		
	}
	
}