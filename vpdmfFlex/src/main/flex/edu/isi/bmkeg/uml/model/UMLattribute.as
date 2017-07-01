package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLrole;
	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.uml.model.UMLitem;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLattribute")]
	public class UMLattribute extends UMLitem
	{
		public function UMLattribute(){}

		public var parentClass:UMLclass;

		public var type:UMLclass;
		
		public var fkRole:UMLrole;
		
		public var pk:UMLattribute;
		
		public var fk:ArrayCollection;
		
	}
}