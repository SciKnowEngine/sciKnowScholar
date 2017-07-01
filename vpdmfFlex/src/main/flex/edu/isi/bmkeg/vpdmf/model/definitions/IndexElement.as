package edu.isi.bmkeg.vpdmf.model.definitions
{
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.IndexElement")]
	public class IndexElement
	{
		public function IndexElement(){}

		public var serialVersionUID:Number;
		public var position:int;
		public var attributeAddress:String;
		public var nullable:Boolean;
	}
}