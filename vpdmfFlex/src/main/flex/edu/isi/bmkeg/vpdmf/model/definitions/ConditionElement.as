package edu.isi.bmkeg.vpdmf.model.definitions
{
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.ConditionElement")]
	public class ConditionElement
	{
		public function ConditionElement(){}

		public var serialVersionUID:Number;
		public var className:String;
		public var attName:String;
		public var value:String;
		public var pvCount:int;
	}
}