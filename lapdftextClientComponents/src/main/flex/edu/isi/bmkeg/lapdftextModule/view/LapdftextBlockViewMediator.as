package edu.isi.bmkeg.lapdftextModule.view
{

	import edu.isi.bmkeg.digitalLibrary.events.*;
	import edu.isi.bmkeg.digitalLibrary.model.citations.*;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.digitalLibrary.rl.events.*;
	import edu.isi.bmkeg.digitalLibraryModule.events.*;
	import edu.isi.bmkeg.ftd.model.*;
	import edu.isi.bmkeg.ftd.model.qo.*;
	import edu.isi.bmkeg.ftd.rl.events.*;
	import edu.isi.bmkeg.lapdftextModule.events.*;
	import edu.isi.bmkeg.lapdftextModule.model.*;
	import edu.isi.bmkeg.pagedList.*;
	import edu.isi.bmkeg.pagedList.model.*;
	import edu.isi.bmkeg.terminology.model.Term;
	import edu.isi.bmkeg.terminology.model.qo.Term_qo;
	import edu.isi.bmkeg.terminology.rl.events.*;
	import edu.isi.bmkeg.utils.dao.Utils;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.conversion.TextConverter;
	
	import mx.collections.*;
	import mx.collections.ArrayCollection;
	import mx.collections.ItemResponder;
	import mx.collections.errors.ItemPendingError;
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	import mx.core.IFactory;
	import mx.events.CollectionEvent;
	import mx.graphics.*;
	import mx.managers.PopUpManager;
	import mx.utils.StringUtil;
	
	import org.ffilmation.utils.rtree.*;
	import org.libspark.utils.ForcibleLoader;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.IndexChangeEvent;
	import spark.primitives.*;
	
	public class LapdftextBlockViewMediator extends Mediator
	{
		
		[Inject]
		public var view:LapdftextBlockView;
		
		[Inject]
		public var model:LapdftextModel;
		
		private var xml:XML;
				
		override public function onRegister():void {
			
			addViewListener(RemoveAnnotationEvent.REMOVE_ANNOTATION, 
				dispatch);
			
			addViewListener(ChangeLapdftexBlockViewEvent.CHANGE_LAPDFTEXTBLOCK_VIEW, 
				manageChanges);

			addViewListener(RunRuleSetOnArticleCitationEvent.RUN_RULE_SET_ON_ARTICLE_CITATION, 
				runRules);
			
			addContextListener(
				FindArticleCitationByIdResultEvent.FIND_ARTICLECITATIONBY_ID_RESULT, 
				buildBitmapsFromFindByIdResult);

			addContextListener(
				RetrieveFTDRuleSetForArticleCitationResultEvent.RETRIEVE_FTDRULESET_FOR_ARTICLE_CITATION_RESULT, 
				updateRuleSet);

			addContextListener(
				GenerateRuleFileFromLapdfResultEvent.GENERATE_RULE_FILE_FROM_LAPDF_RESULT, 
				updateCsv);
			
			addContextListener(LoadSwfResultEvent.LOAD_SWF_RESULT, 
				swfFileLoadResult);
			
			addContextListener(LoadXmlResultEvent.LOAD_XML_RESULT, 
				xmlFileLoadResult);

			addContextListener(LoadHtmlResultEvent.LOAD_HTML_RESULT, 
				loadHtmlResult);
			
			addViewListener(RetrievePmcHtmlEvent.RETRIEVE_PMC_HTML, 
				loadHtmlResult);

			this.dispatch( new ListTermViewsEvent() );
			
			if( model.citation != null ) {
				this.buildBitmaps( model.citation.vpdmfId );
			}

		}

		private function runRules(event:RunRuleSetOnArticleCitationEvent):void {
			if( model.citation == null )
				return;
			
			event.articleId = model.citation.vpdmfId;
			dispatch(event);
		}

		private function updateCsv(event:GenerateRuleFileFromLapdfResultEvent):void {
			view.csv = event.csv;
		}
		
		private function updateRuleSet(event:RetrieveFTDRuleSetForArticleCitationResultEvent):void {
			
			if( event.ruleSet == null ) {
				this.view.ruleSet = new FTDRuleSet();				
				this.view.ruleSet.fileName = "---general.drl---";				
			} else {
				this.view.ruleSet = event.ruleSet;
			}
		
		}
		
		private function manageChanges(event:ChangeLapdftexBlockViewEvent):void {
			
			var alpha:Number = -1.0;
			var state:int = -1;
			if( event.pgOrBlocks == "Page Images" ) {
				state = 0;
				alpha = 1.0;					
			} else if( event.pgOrBlocks == "Block Classification" ) {
				state = 1;
				alpha = 0.0;
			} else if( event.pgOrBlocks == "Block Font + Style" ) {
				state = 2;
				alpha = 0.0;
			} else {
				// throw new Exception();
			}
						
			for( var i:int = 0; i<view.bitmaps.length; i++) {
				var bh:LapdftextBlockHolder = readLapdftextBlockHolder(i);		
				bh.alpha = alpha;			
				bh.state = state;
			}
			
			this.forceRedraw();
						
		}

		private function buildBitmapsFromFindByIdResult(event:FindArticleCitationByIdResultEvent):void {

			this.view.pgImgButton.selected = true;
			this.view.currentState = "showPages";
			
			this.buildBitmaps( event.object.vpdmfId );
			
			// We need to identify the correct rule set for this paper.
			//this.dispatch( new RetrieveFTDRuleSetForArticleCitationEvent(event.object.vpdmfId) );
			
			// We also need to generate and store a temporary CSV file
			//this.dispatch( new GenerateRuleFileFromLapdfEvent(event.object.vpdmfId) );
			
		}
		
		private function buildBitmaps(vpdmfId:Number):void{
			
			//
			// First, get the swf file on the server for the images
			//
			this.dispatch( new LoadSwfEvent(vpdmfId) );
			
			//
			// Next, get the xml for the page boxes
			//
			this.dispatch( new LoadXmlEvent(vpdmfId) );
				
			//
			// Finally, get the html for the text of the document 
			// (this is the end product that we will annotate)
			//
			this.dispatch( new LoadHtmlEvent(vpdmfId) );
			
			view.bitmaps = new ArrayCollection();
			
		}

		private function readLapdftextBlockHolder(pMinusOne:int):LapdftextBlockHolder {
			
			var fh:LapdftextBlockHolder;
			
			if( view.bitmaps.length <= pMinusOne ) {
				fh = new LapdftextBlockHolder(model.pdfScale);
				fh.page = pMinusOne + 1;
				view.bitmaps.addItem(fh);
			} else {
				fh = LapdftextBlockHolder(view.bitmaps.getItemAt(pMinusOne));
			}
			
			return fh;
			
		}

		private function swfFileLoadResult(event:LoadSwfResultEvent):void {
			
			var clip:MovieClip = event.swf;
			
			var frames:int = clip.totalFrames;
			
			for(var i:int=1; i<=frames; i++){
				clip.gotoAndStop(i)
				var bitmapData:BitmapData = new BitmapData(
					clip.width*model.pdfScale, clip.height*model.pdfScale,
					true, 0x00FFFFFF);

				var mat:Matrix=new Matrix();
				mat.scale(model.pdfScale,model.pdfScale);

				bitmapData.draw(clip, mat);
				var o:LapdftextBlockHolder = readLapdftextBlockHolder(i-1);			
				o.image = new Bitmap(bitmapData);
			}

			this.forceRedraw();				
			
		}
		
		private function xmlFileLoadResult(event:LoadXmlResultEvent):void {
			
			xml = XML(event.xml);
			
			//
			// Build the spatial index of the PDF content here. 
			//
			model.rTreeArray = new ArrayCollection();
			model.indexedWordsByPage = new ArrayCollection();
		
			var p:int = 0; 
			for each(var pageXml:XML in xml.pages[0].*) {

				var rTree:fRTree = new fRTree();
				model.rTreeArray.addItemAt(rTree,p);
				
				var words:ArrayCollection = new ArrayCollection();
				model.indexedWordsByPage.addItemAt(words,p);
		
				var fh:LapdftextBlockHolder = readLapdftextBlockHolder(p);
				fh.extraRectangles = new ArrayCollection();
				
				var wc:int = 0;
				for each(var chunkXml:XML in pageXml.chunks[0].*) {	
					
					if(model.drawChunksFlag) {
						var xx1:Number = Number(chunkXml.@x);
						var yy1:Number = Number(chunkXml.@y);
						var xx2:Number = xx1 + Number(chunkXml.@w);
						var yy2:Number = yy1 + Number(chunkXml.@h);					
						var oo:Object = {"x1":xx1, "y1":yy1, "x2":xx2, "y2":yy2, 
							"c":chunkXml.@type, "f":chunkXml.@font, "sz":chunkXml.@fontSize}; 
						fh.extraRectangles.addItem(oo);						
					}
					
					for each(var wordXml:XML in chunkXml.words[0].*) {
						
						var xxx1:Number = wordXml.@x;
						var yyy1:Number = wordXml.@y;
						var zzz1:Number = 0;
						var xxx2:Number = xxx1 + Number(wordXml.@w);
						var yyy2:Number = yyy1 + Number(wordXml.@h);
						var zzz2:Number = 1;
						var w:String = new String(wordXml.@t[0]);
						
						var c:fCube = new fCube(xxx1, yyy1, zzz1, xxx2, yyy2, zzz2);
						rTree.addCube(c, wc);
						words.addItemAt(wordXml, wc);
						
						//trace(wc+ " - p: "+p+", x:"+x1+", y:"+y1+", w:"+w);
						
						wc++;
						
						if(model.drawWordsFlag) {
							
							var ooo:Object = {"x1":xxx1, "y1":yyy1, "x2":xxx2, "y2":yyy2}; 
							fh.extraRectangles.addItem(oo);
							
						}
						
					}
					
				}
				
				p++;
			
			}

			this.forceRedraw();				
		
		}
		
		
		private function htmlFileLoadError(event:ErrorEvent):void {
			
			trace("Text is not available for this document: " + event);
			
		}
		
		private function loadHtmlResult(event:Event):void {

			var htmlString:String = model.pmcHtml;
			
			if( htmlString != null && view.lapdfTextControl != null) {
				view.lapdfTextControl.textFlow = TextConverter.importToFlow(
						htmlString, TextConverter.TEXT_FIELD_HTML_FORMAT);
			}
			
		}
		
		private function eventDrivenRedraw(event:Event):void {
			this.forceRedraw();
		}
		
		//
		// Force a redraw for the List control.
		// from: http://blog.9mmedia.com/?p=709
		//
		private function forceRedraw():void {
			var _itemRenderer:IFactory = this.view.pgList.itemRenderer;
			this.view.pgList.itemRenderer = null;
			this.view.pgList.itemRenderer = _itemRenderer;
		}
		
				
	}

}