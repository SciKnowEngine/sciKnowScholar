package edu.isi.bmkeg.utils.kmrgGraph
{
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode")]
	public class kmrgGraphNode
	{
		public function kmrgGraphNode(){}

		public var serialVersionUID:Number;
		public var name:String;
		public var displayable:Boolean;
		public var deleteFlag:Boolean;
		public var alias:String;
		public var tag:int;
		public var inEdges:Object = new Object();
		public var outEdges:Object = new Object();
		public var graph:kmrgGraph;
		public var subGraph:kmrgGraph;
	}
	
}