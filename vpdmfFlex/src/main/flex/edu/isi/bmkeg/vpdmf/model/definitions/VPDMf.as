package edu.isi.bmkeg.vpdmf.model.definitions
{
	import edu.isi.bmkeg.vpdmf.model.definitions.viewGraphDefinition;
	import edu.isi.bmkeg.uml.model.UMLmodel;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.VPDMf")]
	public class VPDMf
	{
		public function VPDMf(){}

		public var serialVersionUID:Number;
		public var vpdmfLogin:String;
		public var vpdmfPassword:String;
		public var vGraphDef:viewGraphDefinition;
		public var umlModel:UMLmodel;
		public var vpdmfModel:UMLmodel;
		public var startView:String;
		public var views:Object;
	}
	
}