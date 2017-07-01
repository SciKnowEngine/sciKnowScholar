package edu.isi.bmkeg.vpdmf.model.definitions
{
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	import edu.isi.bmkeg.vpdmf.model.definitions.ViewDefinition;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinition")]
	public class PrimitiveDefinition extends kmrgGraphNode
	{
		public function PrimitiveDefinition(){}

		public var conditions:String;
		public var editable:Boolean;
		public var nullable:Boolean;
		public var unique:Boolean;
		public var primaryClass:UMLclass;
		public var view:ViewDefinition;
		public var lookupView:ViewDefinition;
		public var lookupViewLookup:String;
		public var classes:ArrayCollection;
		public var internalRoles:ArrayCollection;
		public var conditionElements:ArrayCollection;
		
		public function readAttributes():ArrayCollection {
			var attrs:ArrayCollection = new ArrayCollection();
			
			for each (var c:UMLclass in this.classes) {
				
				for each (var a:UMLattribute in c.attributes) {
					attrs.addItem(a);
				}
			}
			
			return attrs;			
		}
		
		
	}
}