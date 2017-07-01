package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	import edu.isi.bmkeg.vpdmf.model.definitions.ViewDefinition;
	
	import mx.collections.ArrayCollection;

	
	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance")]
	public class LightViewInstance extends kmrgGraphNode
	{
		public function LightViewInstance(){}
		
		public var vpdmfId:Number;
		public var vpdmfLabel:String;
		public var vpdmfUri:String;
		public var UIDString:String;
		public var definition:ViewDefinition;
		public var defName:String;
		public var indexTuple:String;
		public var indexTupleFields:String;

		public function convertToIndexTupleObject():Object {
			
			var o:Object = new Object();
			o.vpdmfLabel = this.vpdmfLabel;
			o.vpdmfId = this.vpdmfId;
			var fields:Array = this.indexTupleFields.split(/\{\|\}/);
			var tuple:Array = this.indexTuple.split(/\{\|\}/);
			
			for(var i:int=0; i<fields.length; i++) {
				var f:String = fields[i] as String;
				var v:String = tuple[i] as String;			
				if( v == null )
					v = "";
				v = v.replace(/,/,", ");
				o[f]=v;	
			}
			
			return o;
			
		}

		public function clone():LightViewInstance {
			
			var o:LightViewInstance = new LightViewInstance();
			
			o.alias = this.alias;
			o.defName = this.defName;
			o.displayable = this.displayable;
			o.indexTupleFields = this.indexTupleFields;
			o.indexTuple = this.indexTuple;
			o.name = this.name;
			o.vpdmfLabel = this.vpdmfLabel;
			o.vpdmfId = this.vpdmfId;
			
			return o;
			
		}
		
	}
	
}


	
