package edu.isi.bmkeg.lapdftextModule.model
{
	
	import edu.isi.bmkeg.ftd.model.FTD;
	import edu.isi.bmkeg.ftd.model.FTDRuleSet;
	import edu.isi.bmkeg.ftd.model.qo.FTD_qo;
	
	import edu.isi.bmkeg.digitalLibrary.model.citations.*;
	import edu.isi.bmkeg.digitalLibrary.model.qo.citations.*;
	import edu.isi.bmkeg.ftd.model.FTD;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import flash.display.*;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.ByteArrayAsset;
	import mx.utils.UIDUtil;
	
	import org.robotlegs.mvcs.Actor;
	
	[Bindable]
	public class LapdftextModel extends Actor
	{
		public var listPageSize:int = 200;
		
		public var journals:ArrayCollection = new ArrayCollection();
		
		public var epochList:ArrayCollection = new ArrayCollection();
		
		public var epoch:JournalEpoch;
		
		public var ftds:ArrayCollection = new ArrayCollection();
				
		public var currentFtd:FTD;

		public var queryFtd:FTD_qo;

		public var nDoc:Number;
		
		public var ruleSetList:ArrayCollection = new ArrayCollection();
		
		public var ruleSet:FTDRuleSet;

		public var ruleSetCsv:String;
		
		// conditions that specify the articles currently listed
		public var queryLiteratureCitation:ArticleCitation_qo;
		
		// the selected article
		public var citation:ArticleCitation;
		
		// A light version (equivalent of a LightViewInstance) of the FTD associated with the citation
		// We don't load the 'heavy' swf data or the lapdftext binary over the application's 
		// standard amf interface to cut down the I/O to just what is needed. 
		public var lightFtd:FTD;
		
		// the SWF of the PDF file
		public var swf:MovieClip;
		
		public var drawWordsFlag:Boolean = false;
		public var drawChunksFlag:Boolean = true;
		public var drawPagesFlag:Boolean = true;
		
		// An array of adapted org.ffilmation.utils.rtree.fRTree objects 
		public var rTreeArray:ArrayCollection = new ArrayCollection();
		
		// An array of arrays of words, indexed by page, then by rtree index
		public var indexedWordsByPage:ArrayCollection = new ArrayCollection();
		
		// The fragmenter renders each page as a bitmap. This is the scaling factor 
		// used to mitigate pixelation so that the pages look OK in the interface.
		public var pdfScale:Number = 2.0;

		// The text of the current PDF file expressed as a PMC file.
		public var pmcHtml:String;

		[Embed(source="/edu/isi/bmkeg/digitalLibrary/Journal.txt",
				mimeType="application/octet-stream")]
		private var JournalTextFileClass : Class;
		
		public function LapdftextModel() {
			
			var journalFileByteArray:ByteArrayAsset = ByteArrayAsset(new JournalTextFileClass());
			var journalFile:String = journalFileByteArray.readUTFBytes(journalFileByteArray.length);

			var lines:Array = journalFile.split(/\r/);			
			for( var i:int = 1; i < lines.length; i++ ) {
				var line:String = String(lines[i]);
				var fields:Array = line.split(/\t/);
				var o:Object = new Object();
				o["vpdmfId"] = String(fields[0]); 
				o["title"] = String(fields[1]); 
				o["abb"] = String(fields[3]); 				
				journals.addItem(o);
			}
						
		}
		
	}

}