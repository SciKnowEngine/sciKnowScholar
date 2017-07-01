package edu.isi.bmkeg.utils.kmrgGraph
{
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphEdge")]
	public class kmrgGraphEdge
	{
		public function kmrgGraphEdge(){}

		public var serialVersionUID:Number;
		public var id:String;
		public var label:String;
		public var displayable:Boolean;
		public var directed:Boolean;
		public var deleteFlag:Boolean;
		public var inEdgeNode:kmrgGraphNode;
		public var outEdgeNode:kmrgGraphNode;
		public var graph:kmrgGraph;
	}
}