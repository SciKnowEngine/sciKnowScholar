package edu.isi.bmkeg.uml.model
{
	import edu.isi.bmkeg.uml.model.UMLpackage;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.uml.model.UMLmodel")]
	public class UMLmodel
	{
		public function UMLmodel(){}

		public var serialVersionUID:Number;
		public var XMI_POSEIDON:String;
		public var XMI_MAGICDRAW:String;
		public var XMI_ARGOUML:String;
		public var SQL_MYSQL:String;
		public var DATALOG:String;
		public var JAVA_IMPL:String;
		public var MYSQL_IMPL:String;
		public var UML_IMPL:String;
		public var DLOG_IMPL:String;
		public var AS_IMPL:String;
		
		public var imp:String;
		
		public var id:Number;
		
		public var name:String;
		public var url:String;
		public var description:String;

		public var items:Object;
		public var topPackage:UMLpackage;
		
		public var sourceType:String;
		public var sourceData:int;
	}
}