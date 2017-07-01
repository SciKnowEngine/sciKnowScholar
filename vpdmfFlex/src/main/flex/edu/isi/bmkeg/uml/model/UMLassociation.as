package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLrole;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLitem;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLassociation")]
	public class UMLassociation extends UMLitem
	{
		public function UMLassociation(){}

		public var role1:UMLrole;
		public var role2:UMLrole;
		public var linkClass:UMLclass;
		public var pkg:UMLpackage;
		
	}
}