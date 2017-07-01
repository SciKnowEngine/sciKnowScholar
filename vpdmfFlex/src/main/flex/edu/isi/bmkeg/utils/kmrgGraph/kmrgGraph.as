package edu.isi.bmkeg.utils.kmrgGraph
{
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph")]
	public class kmrgGraph
	{
		public function kmrgGraph(){}

		public var serialVersionUID:Number;
		public var edges:ArrayCollection = new ArrayCollection();
		public var nodes:Object = new Object;
		public var subGraphNode:kmrgGraphNode;
	}
}