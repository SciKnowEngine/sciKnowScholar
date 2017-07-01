package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.model.UMLrole;
	import edu.isi.bmkeg.uml.utils.UMLDataConverters;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraph;
	import edu.isi.bmkeg.utils.kmrgGraph.kmrgGraphNode;
	import edu.isi.bmkeg.vpdmf.model.definitions.ConditionElement;
	import edu.isi.bmkeg.vpdmf.model.definitions.PrimitiveDefinition;
	import edu.isi.bmkeg.vpdmf.model.instances.AttributeInstance;
	import edu.isi.bmkeg.vpdmf.model.instances.ClassInstance;
	import edu.isi.bmkeg.vpdmf.model.instances.PrimitiveInstanceGraph;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.PrimitiveInstance")]
	public class PrimitiveInstance extends kmrgGraphNode
	{
		public function PrimitiveInstance(){}

		public var definition:PrimitiveDefinition;
		public var defName:String;
		public var objects:Object = new Object();
		
		override public function set graph(pig:kmrgGraph):void {
			super.graph = PrimitiveInstanceGraph( pig );
		}
		
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		public function init(pvDef:PrimitiveDefinition):void {
			
			this.defName = pvDef.name;
			
			this.name = pvDef.name + "_0";
			this.definition = pvDef;
			
			for each (var currentClass:UMLclass in pvDef.classes) {
				var ci:ClassInstance = new ClassInstance();
				ci.init(currentClass);
				ci.primitive = this;
				
				this.objects[currentClass.baseName] = ci;
				
			}
			
		}
		
		
		/**
		 * We link the attributes in the model
		 */
		public function linkAttributeInstances():void {
			
			var lookup:Object = new Object();
			
			var pkfks:ArrayCollection = null;
			var att:AttributeInstance = null;
			var def:UMLattribute = null;
			
			var vi:ViewInstance = ViewInstance(this.graph.subGraphNode);
			
			var index:int = readIndex();
			
			var defs:ArrayCollection = new ArrayCollection();
			defs.addAll(this.definition.readAttributes());
			
			for each (var c:ClassInstance in this.objects) {
				for each (var a:AttributeInstance in c.attributes) {
					
					var addr:String = c.defName + "." + a.defName;
					
					if (lookup[addr] != null) {
						throw new Error("Primitive Instance Attributes already joined");
					}
					lookup[addr] = a;
				}
			}
			
			//
			// Link all intra-pv roles
			//
			for each (var r:UMLrole in this.definition.internalRoles) {
				
				for each (var f:UMLattribute in r.fkArray) {
					
					var p:UMLattribute = f.pk;
					var fi:AttributeInstance = AttributeInstance( 
						lookup[f.parentClass.baseName + "." +f.baseName] );
					
					var pi:AttributeInstance = AttributeInstance( 
						lookup[p.parentClass.baseName + "." +p.baseName] );
					
					if (fi != null && pi != null) {
						fi.connectTo(pi);
					} else {
						throw new Error(
							"Can't find linking attributes, error in "
							+ "ViewDefinition: " + "["
							+ vi.definition.name + "]"
							+ this.definition.name + "|"
							+ r.directClass.baseName + "."
							+ r.baseName);
					}
					
				}
				
			}
			
			//
			// Link according to inheritence too.
			//
			var objLookup:Object = new Object();
			
			for each (var obj:ClassInstance in this.objects) {

				objLookup[obj.definition.baseName] = obj;
			
			}
			
			for each (var obj2:ClassInstance in this.objects) {
				
				if (obj2.definition.parent != null) {
					var parentObj:ClassInstance = ClassInstance( 
							objLookup[obj2.definition.parent.baseName] );
					
					//
					// Note:
					//
					// Interesting condition here, Previously, we required that
					// the complete inheritence hierarchy had to be present in
					// a primitives. This is, of course, unnecessary. But we
					// should put some safeguards to make sure that no
					// classInstance is 'disconnected', see below.
					//
					if (parentObj == null) {
						continue;
					}
					
					var parentPks:ArrayCollection = new ArrayCollection();
					parentPks.addAll(parentObj.definition.pkArray);
					
					var childPks:ArrayCollection = new ArrayCollection();
					childPks.addAll( obj2.definition.pkArray );
					for (var i:int = 0; i < parentPks.length; i++) {
						var childPk:UMLattribute = UMLattribute( childPks[i] );
						var childAi:AttributeInstance = AttributeInstance(
							lookup[childPk.parentClass.baseName + "." +childPk.baseName]);
						
						var parentPk:UMLattribute = UMLattribute( parentPks[i] );
						var parentAi:AttributeInstance = AttributeInstance( 
							lookup[parentPk.parentClass.baseName + "." +parentPk.baseName]);
						
						parentAi.connectTo(childAi);
						
					}
					
				}
				
			}
			
			//
			// Note:
			//
			// Check for disconnected classInstances
			//
			if( this.objects.length > 1 ) {
				for each (var obj3:ClassInstance in this.objects) {
					
					var isDisconnected:Boolean = true;
					
					for each (var ai:AttributeInstance in obj3.attributes) {
						if (ai.connectedKeys.length > 0) {
							isDisconnected = false;
							break;
						}
					}
					if (isDisconnected) {
						throw new Error("]" + this.definition.name + "|"
							+ obj3.definition.baseName
							+ " is disconnected.");
					}
					
				}
			}			
		}
		
		public function readIndex():int {
			
			var piName:String = this.name;
			var pos:int = piName.lastIndexOf('_');
			var iString:String = piName.substring(pos + 1);
			var index:int = int(iString);
			
			return index;
			
		}
		
		
		public function fillInConditions():void {
			
			if (this.definition.conditionElements.length == 0) {
				return;
			}
			
			for each (var ce:ConditionElement in this.definition.conditionElements) {
					
				var ai:AttributeInstance = readAttribute("|" + ce.className 
						+ "." + ce.attName);
					
				var data:Object = UMLDataConverters.convertToType(
					ai.definition, ce.value);
					
				ai.value = data;
					
			}			
		
		}
		
		public function readAttribute(attributeAddress:String):AttributeInstance {
			
			var classIns:ClassInstance = null;
			var attrIns:AttributeInstance = null;
			
			//
			// Check the format of the attributeAddress
			//
			var dotPos:int = attributeAddress.lastIndexOf('.');
			var barPos:int = attributeAddress.lastIndexOf('|');
			
			if (dotPos == -1 || barPos == -1) {
				throw new Error(attributeAddress + " is badly formed\n");
			}
			
			var attributeName:String = attributeAddress.substring(dotPos + 1);
			var className:String = attributeAddress.substring(barPos + 1, dotPos);
			
			//
			// ii) Class
			if (this.objects[className] != null ) {
				classIns = ClassInstance( this.objects[className] );
			} else {
				throw new Error("Can't find " + attributeAddress
					+ ", no such class\n");
			}
			
			//
			// iii) Attribute
			if (classIns.attributes[attributeName] != null) {
				attrIns = AttributeInstance( classIns.attributes[attributeName] );
			} else {
				throw new Error("Can't find " + attributeAddress
					+ ", no such attribute\n");
			}
			
			return attrIns;
			
		}
		
		public function removeDefinition():void {
			
			this.definition = null;
			
			for each (var ci:ClassInstance in this.objects) {
				ci.removeDefinition();
			}
			
		}
		
		
		
	}
	
}