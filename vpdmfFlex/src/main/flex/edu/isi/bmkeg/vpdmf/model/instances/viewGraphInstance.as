package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.vpdmf.model.definitions.viewGraphDefinition;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.viewGraphInstance")]
	public class viewGraphInstance extends kmrgGraph
	{
		public function viewGraphInstance(){}

		public var definition:viewGraphDefinition;
	}
}