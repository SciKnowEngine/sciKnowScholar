package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.vpdmf.model.instances.ViewInstance;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphEdge;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.RelationInstance")]
	public class RelationInstance extends kmrgGraphEdge
	{
		public function RelationInstance(){}

		public var rlnView:ViewInstance;
	}
}