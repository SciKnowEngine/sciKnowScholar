package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLassociation;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLpackage;
	import edu.isi.bmkeg.uml.model.UMLitem;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLclass")]
	public class UMLclass extends UMLitem
	{
		public function UMLclass(){}

		public var dataType:Boolean;

		public var pkg:UMLpackage;

		public var parent:UMLclass;
		public var children:ArrayCollection;
		
		public var associateRoles:Object;
		public var directRoles:ArrayCollection;
		
		public var linkAssociation:UMLassociation;

		public var classAddress:String;
		public var operations:ArrayCollection;
		public var attributes:ArrayCollection;
		public var pkArray:ArrayCollection;
	}
}