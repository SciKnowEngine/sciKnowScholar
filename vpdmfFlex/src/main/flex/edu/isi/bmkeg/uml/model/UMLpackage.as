package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLpackage;
	import edu.isi.bmkeg.uml.model.UMLitem;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLpackage")]
	public class UMLpackage extends UMLitem
	{
		public function UMLpackage(){}

		public var pkgAddress:String;
		public var namespace:String;

		public var classes:ArrayCollection;
		public var associations:ArrayCollection;

		public var children:ArrayCollection;
		public var parent:UMLpackage;

	}

}