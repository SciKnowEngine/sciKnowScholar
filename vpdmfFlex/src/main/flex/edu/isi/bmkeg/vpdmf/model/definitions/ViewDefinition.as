package edu.isi.bmkeg.vpdmf.model.definitions
{
	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.vpdmf.model.definitions.ViewDefinition;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinition;
	import edu.isi.bmkeg.vpdmf.model.definitions.VPDMf;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.ViewDefinition")]
	public class ViewDefinition extends kmrgGraphNode
	{
		public function ViewDefinition(){}

		public var type:int;
		public var DATA:int;
		public var SYSTEM:int;
		public var LOOKUP:int;
		public var LINK:int;
		public var COLLECTION:int;
		public var EXTERNAL:int;
		public var IN:int;
		public var OUT:int;
		public var LINKS:int;
		public var RELATIONS:int;
		public var BOTH:int;
		
		public var specification:String;
		public var indexstringFormat:String;
		public var machineIndexFormat:String;
		public var indexstring:UMLattribute;
		public var machineIndex:UMLattribute;
		public var editable:Boolean;
		public var documentation:String;
		public var parent:ViewDefinition;
		public var altName:String;
		public var primaryPrimitive:PrimitiveDefinition;
		public var dependencies:ArrayCollection;
		public var relations:ArrayCollection;
		public var isa:ArrayCollection;
		public var indexElements:Object;
		public var top:VPDMf;
	}
}