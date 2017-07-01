package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLmodel;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLitem")]
	public class UMLitem
	{
		public function UMLitem(){}

		public var serialVersionUID:Number;
		public var id:Number;
		public var uuid:String;
		public var implName:String;
		public var baseName:String;
		public var stereotype:String;
		public var isNew:Boolean;
		public var designed:Boolean;
		public var toImplement:Boolean;
		public var model:UMLmodel;
		public var uri:String;
		public var documentation:String;
	}
}