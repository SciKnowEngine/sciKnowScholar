package edu.isi.bmkeg.lapdftextModule.controller
{	
	import edu.isi.bmkeg.lapdftextModule.model.LapdftextModel;
	
	import edu.isi.bmkeg.digitalLibrary.events.ListExtendedJournalEpochsResultEvent;
	import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Command;
	
	public class ListExtendedJournalEpochsResultCommand extends Command
	{
		
		[Inject]
		public var event:ListExtendedJournalEpochsResultEvent;
		
		[Inject]
		public var model:LapdftextModel;
	
		override public function execute():void
		{
						
			var l:ArrayCollection = new ArrayCollection();

			for each(var lvi:LightViewInstance in event.epochList) {
					
				var o:Object = new Object();
				o.vpdmfLabel = lvi.vpdmfLabel;
				o.vpdmfId = lvi.vpdmfId;
				var fields:Array = lvi.indexTupleFields.split(/\{\|\}/);
				var tuple:Array = lvi.indexTuple.split(/\{\|\}/);
					
				for(var i:int=0; i<fields.length; i++) {
					var f:String = fields[i] as String;
					var v:String = tuple[i] as String;	
					if( v == null )
						v = "";
					if( f == "JournalEpoch_4" && v == "null" ) {
						v = "---general.drl---";	
					}
					v = v.replace(/,/,", ");
					o[f]=v;	
				}
					
				l.addItem(o);
				
			}

			model.epochList = l;
			
		}
		
	}
	
}