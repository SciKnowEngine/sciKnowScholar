package edu.isi.bmkeg.vpdmf.model.definitions
{
	import edu.isi.bmkeg.vpdmf.model.definitions.VPDMf;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.viewGraphDefinition")]
	public class viewGraphDefinition extends kmrgGraph
	{
		public function viewGraphDefinition(){}

		public var top:VPDMf;
	}
}