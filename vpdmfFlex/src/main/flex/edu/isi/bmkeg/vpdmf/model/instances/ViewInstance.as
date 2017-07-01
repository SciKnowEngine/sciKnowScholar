package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLmodel;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinition;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinitionGraph;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveLink;
	import edu.isi.bmkeg.vpdmf.model.definitions.ViewDefinition;
	import edu.isi.bmkeg.vpdmf.model.instances.PrimitiveInstance;
	import edu.isi.bmkeg.vpdmf.model.instances.PrimitiveInstanceGraph;
	import edu.isi.bmkeg.vpdmf.model.instances.viewGraphInstance;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.ViewInstance")]
	public class ViewInstance extends LightViewInstance 
	{
		public function ViewInstance(){}

		public var kmID:int;
		public var visible:Boolean;
		public var complete:Boolean;
		public var piTotals:Object = new Object();
		public var primaryPrimitive:PrimitiveInstance;
		public var linksToFillIn:ArrayCollection = new ArrayCollection();

		override public function get subGraph():kmrgGraph {
			return PrimitiveInstanceGraph( this.subGraph );
		}
		
		override public function get graph():kmrgGraph {
			return viewGraphInstance( this.graph );
		}
		
		override public function set subGraph(pig:kmrgGraph):void {
			this.subGraph = PrimitiveInstanceGraph( pig );
		}
		
		override public function set graph(vgi:kmrgGraph):void {
			this.subGraph = viewGraphInstance( vgi );
		}

		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		public function init(vd:ViewDefinition):void {
	
			this.defName = vd.name;
			
			this.vpdmfLabel = "";
			this.UIDString = "";
			
			this.definition = vd;
			
			var lookup:Object = new Object();
			
			var pig:PrimitiveInstanceGraph = new PrimitiveInstanceGraph();
			this.subGraph = pig;
			pig.subGraphNode = this;
			
			var pdg:PrimitiveDefinitionGraph = PrimitiveDefinitionGraph(vd.subGraph);
			pig.definition = pdg;
			
			for each (var pd:PrimitiveDefinition in pdg.nodes) {
		
				var pi:PrimitiveInstance = new PrimitiveInstance();
				pi.init(pd);
				
				if( pd == vd.primaryPrimitive ) 
					this.primaryPrimitive = pi;
				
				pig.addPvInstance(pi);
				pi.fillInConditions();	
				
			}
			
			for each (var currentPvLink:PrimitiveLink in pdg.edges) {
				
				var fromPvDef:PrimitiveDefinition = PrimitiveDefinition(
					currentPvLink.outEdgeNode);

				var toPvDef:PrimitiveDefinition = PrimitiveDefinition(
					currentPvLink.inEdgeNode);
				
				pig.addPvInstanceLink(fromPvDef.name + "_0",
						toPvDef.name + "_0");
									
			}
			
		}
		
		public function readAttributeInstance(
				attributeAddress:String, index:int):AttributeInstance{
			
			var pvIns:PrimitiveInstance;
			var classIns:ClassInstance;
			var attrIns:AttributeInstance;
				
			//
			// Check the format of the attributeAddress
			//
			if (attributeAddress == null)
				return null;
				
			var dotPos:int = attributeAddress.lastIndexOf('.');
			var barPos:int = attributeAddress.lastIndexOf('|');
			var brackPos:int = attributeAddress.lastIndexOf(']');
				
			if (dotPos == -1 || barPos == -1 || brackPos == -1) {
				throw new Error(attributeAddress + " is badly formed\n");
			}
				
			var attributeName:String = attributeAddress.substring(dotPos + 1);
			var className:String = attributeAddress.substring(barPos + 1, dotPos);
			var primitiveName:String = attributeAddress.substring(brackPos + 1, barPos);
				
			//
			// Check for the existence of the attributeAddress
			// i) Primitive Definition
			var pvIndex:String = primitiveName + "_" + index;
			if (this.subGraph.nodes[pvIndex] != null ) {
				pvIns = PrimitiveInstance( this.subGraph.nodes[pvIndex] );
			} else {
				throw new Error("Can't find " + attributeAddress + 
					", no such primitive at index" + index + "\n");
			}
				
			//
			// ii) Class
			if ( pvIns.objects[className] != null ) {
				classIns = ClassInstance( pvIns.objects[className] );
			} else {
				throw new Error("Can't find " + attributeAddress + ", no such class\n");
			}
				
			//
			// iii) Attribute
			if (classIns.attributes[attributeName] != null) {
				attrIns = AttributeInstance( classIns.attributes[attributeName] );
			} else {
				throw new Error("Can't find " + attributeAddress + ", no such attribute\n");
			}
				
			return attrIns;
				
		}
		
		/**
		 * Reading the attribute definition can occur in one of two ways:
		 * 
		 * 1) via a Primitive, i.e., ']pvName|className.attributeName'
		 * 
		 * 2) via the model, i.e., '|classPath.attributeName'
		 * 
		 */
		public function readAttributeDefinition(attributeAddress:String):UMLattribute {
			
			var pvIns:PrimitiveInstance;
			var classIns:ClassInstance;
			
			var classDef:UMLclass;
			var attr:UMLattribute;
			
			//
			// Check the format of the attributeAddress
			//
			if (attributeAddress == null)
				return null;
			
			var dotPos:int = attributeAddress.lastIndexOf('.');
			var barPos:int = attributeAddress.lastIndexOf('|');
			var brackPos:int = attributeAddress.lastIndexOf(']');
			
			if (dotPos == -1 || barPos == -1 || brackPos == -1) {
				throw new Error(attributeAddress + " is badly formed\n");
			}
			
			var attributeName:String = attributeAddress.substring(dotPos + 1);
			var className:String = attributeAddress.substring(barPos + 1, dotPos);
			var primitiveName:String = attributeAddress.substring(brackPos + 1, barPos);
				
			//
			// Check for the existence of the attributeAddress
			// i) Primitive Definition
			var pvIndex:String = primitiveName + "_0";
			if (this.subGraph.nodes[pvIndex] != null ) {
					pvIns = PrimitiveInstance( this.subGraph.nodes[pvIndex]);
			} else {
				throw new Error("Can't find " + attributeAddress
					+ ", no such primitive at index 0\n");
			}
				
			//
			// ii) Class
			if (pvIns.objects[className]) {
				classIns = ClassInstance( pvIns.objects[className]);
				classDef = classIns.definition;
			} else {
				throw new Error("Can't find " + attributeAddress + ", no such class\n");
			}
				
			//
			// iii) Attribute
			var attr2:UMLattribute = null;
			for each (var a:UMLattribute in classDef.attributes) {
				if (a.baseName == attributeName) {
					attr2 = a;
					break;
				}
			}
				
			if (attr2 == null) {
				throw new Error("Can't find " + attributeAddress
					+ ", no such attribute\n");
			}
			
			return attr2;
			
		}
		
		public function removeDefinition():void {
			
			this.definition = null;
			
			var pig:PrimitiveInstanceGraph = PrimitiveInstanceGraph( this.subGraph );
						
			//
			// If there is no pig, then we just flip out and get away from here.
			//
			if (pig == null) {
				return;
			}
			
			pig.definition = null;
			
			for each (var pi:PrimitiveInstance in this.subGraph.nodes) {				
				pi.removeDefinition();
			}
			
			for each (var pli:PrimitiveLinkInstance in this.subGraph.edges) {				
				pli.removeDefinition();
			}
		}		
		
	}
	
}