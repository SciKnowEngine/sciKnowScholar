package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinitionGraph;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinition;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveLink;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.PrimitiveInstanceGraph")]
	public class PrimitiveInstanceGraph extends kmrgGraph
	{
		public function PrimitiveInstanceGraph(){}

		public var definition:PrimitiveDefinitionGraph;

		public function addPvInstance(pi:PrimitiveInstance):void {
			
			this.nodes[pi.name] = pi;
			pi.graph = this;
			
			pi.linkAttributeInstances();
			
		}	
		
		
		public function addPvInstanceLink(fromNodeName:String, toNodeName:String):void {
			
			var fromPvIns:PrimitiveInstance = PrimitiveInstance( this.nodes[fromNodeName] );
			var toPvIns:PrimitiveInstance = PrimitiveInstance( this.nodes[toNodeName] );
			
			if (fromPvIns == null || toPvIns == null) {
				throw new Error("Can't add an edge to the graph, none " +
					"or both of the nodes don't exist");
			}
			
			var fromPvDef:PrimitiveDefinition = PrimitiveDefinition(fromPvIns.definition);
			var toPvDef:PrimitiveDefinition = PrimitiveDefinition(toPvIns.definition);
						
			var pl:PrimitiveLink = PrimitiveLink( fromPvDef.outEdges[toPvDef.name] );
			
			if (pl == null)
				throw new Error("Can't add pvLink to graph\n" +
					toPvDef.name + " not found in " + fromPvDef.name);
			
			var pli:PrimitiveLinkInstance = new PrimitiveLinkInstance();
			pli.init(pl);
			
			pli.graph = this;
			this.edges.addItem(pli);
			
			fromPvIns.outEdges[toNodeName] = pli;
			toPvIns.inEdges[fromNodeName] = pli;
			
			pli.outEdgeNode = fromPvIns;
			pli.inEdgeNode = toPvIns;
			
			pli.linkAttributeInstances();
			
		}
		
		
	}
	
}