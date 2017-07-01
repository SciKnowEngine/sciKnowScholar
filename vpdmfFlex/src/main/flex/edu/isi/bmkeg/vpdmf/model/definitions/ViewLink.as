package edu.isi.bmkeg.vpdmf.model.definitions
{
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphEdge;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.ViewLink")]
	public class ViewLink extends kmrgGraphEdge
	{
		public function ViewLink(){}

		public var name:String;
		public var linkString:String;
		public var outPvDefs:String;
		public var attributeLinkage:String;
		public var inPvDefs:String;
		public var setRelation:String;
		public var IDENTICAL:String;
		public var DISCONNECTED:String;
		public var CONNECTED:String;
		public var INTERCONNECTED:String;
		public var SUPERSET:String;
		public var SUBSET:String;
		public var OVERLAP:String;
		public var INTERDEPENDENT:String;
		public var FORWARDDEPENDENT:String;
		public var REVERSEDEPENDENT:String;
	}
}