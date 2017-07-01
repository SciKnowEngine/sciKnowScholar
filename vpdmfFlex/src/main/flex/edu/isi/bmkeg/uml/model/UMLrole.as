package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLassociation;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLitem;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLrole")]
	public class UMLrole extends UMLitem
	{
		public function UMLrole(){}

		public var ass:UMLassociation;
		public var mult_lower:int;
		public var mult_upper:int;
		public var navigable:Boolean;
		public var associateClass:UMLclass;
		public var directClass:UMLclass;
		public var roleKey:String;
		public var fkArray:ArrayCollection;
		public var implementedBy:ArrayCollection;
		public var implementz:UMLrole;
	}
}