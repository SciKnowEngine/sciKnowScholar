package edu.isi.bmkeg.lapdftextModule.view.forms
{

	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.model.citations.*;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.lapdftextModule.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.*;
	import edu.isi.bmkeg.pagedList.*;
	import edu.isi.bmkeg.pagedList.model.*;
	
	import flash.events.Event;
	
	import mx.collections.ItemResponder;
	import mx.collections.errors.ItemPendingError;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	import mx.managers.PopUpManager;
	import mx.utils.StringUtil;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class CorpusPopupMediator extends Mediator
	{
		
		[Inject]
		public var view:CorpusPopup;
		
		[Inject]
		public var model:LapdftextModel;
		
		override public function onRegister():void {
			
			addViewListener(InsertJournalEpochEvent.INSERT_JOURNALEPOCH, dispatch);
			addViewListener(UpdateJournalEpochEvent.UPDATE_JOURNALEPOCH, dispatch);
			addViewListener(ClosePopupEvent.CLOSE_POPUP, closePopup);
			
			this.view.journals = model.journals;
			
		}
		
		private function closePopup(event:ClosePopupEvent):void {
			
			mediatorMap.removeMediatorByView( event.popup );
			PopUpManager.removePopUp( event.popup );
			
		}
		
		private function updateLookupElements(event:ListTermViewsResultEvent):void {
			
			this.view.journals = model.journals;
			
		}
		
	}
	
}