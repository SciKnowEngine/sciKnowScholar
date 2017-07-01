package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphEdge;

	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.uml.model.UMLrole;
	import edu.isi.bmkeg.uml.model.UMLclass;
	
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinition;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveLink;
	import edu.isi.bmkeg.vpdmf.model.instances.ClassInstance;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.PrimitiveLinkInstance")]
	public class PrimitiveLinkInstance extends kmrgGraphEdge
	{
		public function PrimitiveLinkInstance(){}

		public var linkClass:ClassInstance;
		public var pVLinkDef:PrimitiveLink;
		public var defName:String;
		
		public function init(pL:PrimitiveLink):void {
			this.pVLinkDef = pL;
			
			this.defName = pL.outEdgeNode.name + " "
				+ pL.inEdgeNode.name;
			
			if (pL.role != null && pL.role.implementedBy.length > 0) {
				
				var linkClass:UMLclass = pL.role.ass.linkClass;
				var linkClassInstance:ClassInstance = new ClassInstance();
				linkClassInstance.init(linkClass);
				this.linkClass = linkClassInstance;
				linkClassInstance.primitiveLinkInstance = this;
				
			}
			
		}
		
		
		public function linkAttributeInstances():void {
			var pl:PrimitiveLink = this.pVLinkDef;
			var pig:PrimitiveInstanceGraph = PrimitiveInstanceGraph( this.graph );
			var vi:ViewInstance = ViewInstance( pig.subGraphNode );
			
			var FKs:ArrayCollection = pl.readFKKeys();
			var addresses:ArrayCollection = readAttributeAddresses();
			
			var pi_out:PrimitiveInstance = PrimitiveInstance( this.outEdgeNode );
			var pi_out_index:int = pi_out.readIndex();
			var pi_in:PrimitiveInstance = PrimitiveInstance( this.inEdgeNode );
			var pi_in_index:int = pi_in.readIndex();
			
			for each (var fk:UMLattribute in FKs) {				
				var pk:UMLattribute = fk.pk;
				
				var pkIns:AttributeInstance  = null;
				var fkIns:AttributeInstance  = null;
				var att:AttributeInstance  = null;
				var def:UMLattribute = null;
				
				for each (var address:String in addresses) {				
					
					var s:String = "]" + pi_out.definition.name + "|";
					var l:int = s.length;
					if (address.substr(0,l) == s) {
						att = vi.readAttributeInstance(address, pi_out_index);
					} else {
						att = vi.readAttributeInstance(address, pi_in_index);
					}
					def = vi.readAttributeDefinition(address);
					
					if (fk == def) {
						fkIns = att;
					} else if (pk == def) {
						pkIns = att;
					}
					
				}
				
				if (fkIns == null && this.linkClass != null) {

					LOOP: for each (var att2:AttributeInstance in this.linkClass.attributes) {				
						if (att2.definition == fk) {
							fkIns = att2;
							break LOOP;
						}
					}
				}
				
				if (fkIns == null || pkIns == null) {
					throw new Error("Cannot join attributes between "
						+ pi_out.defName + " & " + pi_in.defName);
				}
				
				fkIns.connectTo(pkIns);
				
			}
			
		}
		
		
		/**
		 * Get the addresses of the linking attributes from each primitive.
		 * 
		 * Note that this does NOT include the attributes of the linking class
		 */
		public function readAttributeAddresses():ArrayCollection {
			
			var attrs:ArrayCollection = new ArrayCollection();
			
			var pl:PrimitiveLink = this.pVLinkDef;
			var pv1:PrimitiveDefinition = PrimitiveDefinition( pl.outEdgeNode );
			var pv2:PrimitiveDefinition = PrimitiveDefinition( pl.inEdgeNode );
			
			var attDefLookup_pv1:ArrayCollection = new ArrayCollection();
			attDefLookup_pv1.addAll(pv1.readAttributes());

			var attDefLookup_pv2:ArrayCollection = new ArrayCollection();
			attDefLookup_pv2.addAll(pv2.readAttributes());
			
			var LinkClassLookup:ArrayCollection = null;
			if (pl.readLinkClass() != null) {
				LinkClassLookup = new ArrayCollection();
				LinkClassLookup.addAll(pl.readLinkClass().attributes);
			} else {
				LinkClassLookup = new ArrayCollection();
			}
			
			//
			// Note:
			//
			// If the role isn't null, then the inter-Pv connection is
			// conventional... role mediated...
			//
			var role:UMLrole = pl.role;
			if (role != null) {
				
				// Run through the implemented roles to find out 
				// where they terminate in their
				// respective primitives.
				var roles:ArrayCollection = new ArrayCollection();
				if( role.implementedBy.length > 0 ) {
					roles = role.implementedBy;
				} else {
					roles.addItem(role);
				}
				
				for each (var role2:UMLrole in roles) {				
					
					for each (var fk:UMLattribute in role2.fkArray) {				
						var pk:UMLattribute = fk.pk;
						var fkPv:String = null;
						var pkPv:String = null;
						
						if (attDefLookup_pv1.contains(pk)
							&& attDefLookup_pv2.contains(fk)) {
							pkPv = pv1.name;
							fkPv = pv2.name;
						} else if (attDefLookup_pv1.contains(fk)
							&& attDefLookup_pv2.contains(pk)) {
							fkPv = pv1.name;
							pkPv = pv2.name;
						} else if (attDefLookup_pv1.contains(pk)
							&& LinkClassLookup.contains(fk)) {
							pkPv = pv1.name;
						} else if (attDefLookup_pv2.contains(pk)
							&& LinkClassLookup.contains(fk)) {
							pkPv = pv2.name;
						}
						
						if (fkPv != null) {
							attrs.addItem("]" + fkPv + "|"
								+ fk.parentClass.baseName + "."
								+ fk.baseName);
						}
						if (pkPv != null) {
							attrs.addItem("]" + pkPv + "|"
								+ pk.parentClass.baseName + "."
								+ pk.baseName);
						}
						
					}
					
				}
				
			}
			//
			// Note:
			//
			// If the role is not null, then the inter-Pv connection is
			// unconventional... and is a parent -> child relationship
			//
			else {
				
				for each (var fk2:UMLattribute in pv2.primaryClass.pkArray) {				
					var pk2:UMLattribute = fk2.pk;
					var fkPv2:String = pv2.name;
					var pkPv2:String = pv1.name;
					
					attrs.addItem("]" + fkPv2 + "|" + fk2.parentClass.baseName
						+ "." + fk2.baseName);
					
					attrs.addItem("]" + pkPv2 + "|" + pk2.parentClass.baseName
						+ "." + pk2.baseName);
				}
				
			}
			
			return attrs;
			
		}
		
		public function removeDefinition():void {
			
			this.pVLinkDef = null;
			
			if (this.linkClass != null) {
				this.linkClass.removeDefinition();
			}
			
		}
		
		
	}
}