package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.vpdmf.model.instances.ClassInstance;
	import edu.isi.bmkeg.vpdmf.model.definitions.ViewLink;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphEdge;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.ViewLinkInstance")]
	public class ViewLinkInstance extends kmrgGraphEdge
	{
		public function ViewLinkInstance(){}

		public var linkClass:ClassInstance;
		public var definition:ViewLink;
	}
}