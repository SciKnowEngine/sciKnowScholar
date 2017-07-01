package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.uml.model.UMLitem;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLoperation")]
	public class UMLoperation extends UMLitem
	{
		public function UMLoperation(){}

		public var parentClass:UMLclass;
		public var parameters:ArrayCollection;
		public var returnType:UMLattribute;
		public var code:String;
		public var isStatic:Boolean;

	}

}