package edu.isi.bmkeg.utils.kmrgGraph
{
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphEdge;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphTraversal")]
	public class kmrgGraphTraversal
	{
		public function kmrgGraphTraversal(){}

		public var roots:ArrayCollection;
		public var nodeTraversal:kmrgGraphNode;
		public var edgeTraversal:kmrgGraphEdge;
		public var graph:kmrgGraph;
	}
}