package edu.isi.bmkeg.vpdmf.model.definitions
{
	import edu.isi.bmkeg.uml.model.UMLrole;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLassociation;
	
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphEdge;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveLink")]
	public class PrimitiveLink extends kmrgGraphEdge
	{
		public function PrimitiveLink(){}

		public var role:UMLrole;
		
		override public function set displayable(displayable:Boolean):void {
			super.displayable = displayable;
		}
		
		public function readFKKeys():ArrayCollection {
			var v:ArrayCollection = new ArrayCollection();
			var r:UMLrole = this.role;
			
			//
			// Note:
			//
			// If the role is set to null, then this pvlink is Parent->Child
			//
			if (r == null) {
				
				var childPv:PrimitiveDefinition = PrimitiveDefinition( this.inEdgeNode );
				var primaryClass:UMLclass = childPv.primaryClass;
				v.addAll(primaryClass.pkArray);
				
			} else if (r.implementedBy.length > 0) {
				
				for each (var tempR:UMLrole in r.implementedBy) {				
					v.addAll(tempR.fkArray);
				}
				
			} else {
			
				v.addAll(this.role.fkArray);
			
			}
			
			return v;
			
		}
		
		public function readLinkClass():UMLclass {
			if (this.role == null)
				return null;
			
			var ass:UMLassociation = this.role.ass;
			
			return ass.linkClass;
						
		}

		
		
	}
}