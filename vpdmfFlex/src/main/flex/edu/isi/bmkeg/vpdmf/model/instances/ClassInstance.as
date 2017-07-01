package edu.isi.bmkeg.vpdmf.model.instances
{

	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.vpdmf.model.instances.AttributeInstance;
	import edu.isi.bmkeg.vpdmf.model.instances.PrimitiveInstance;
	import edu.isi.bmkeg.vpdmf.model.instances.PrimitiveLinkInstance;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.ClassInstance")]
	public class ClassInstance
	{
		public function ClassInstance(){}

		public var serialVersionUID:Number;
		public var primitiveLinkInstance:PrimitiveLinkInstance;
		public var definition:UMLclass;
		public var defName:String;
		public var attributes:Object = new Object();
		public var primitive:PrimitiveInstance;
	
	
		public function init(classDef:UMLclass): void {
			this.definition = classDef;
			
			this.defName = classDef.baseName;
					
			for each (var ad:UMLattribute in classDef.attributes) {
				
				// TODO: CHECK
				// ADDED BY GULLY 08/01/2011
				if( !ad.toImplement )
					continue;
				
				var ai:AttributeInstance = new AttributeInstance();
				ai.init(ad);
				
				this.attributes[ad.baseName] = ai;
				ai.object = this;
				
			}
				
		}
		
		public function removeDefinition():void {
			this.definition = null;
			
			for each (var ai:AttributeInstance in this.attributes) {
				ai.removeDefinition();
			}
		}
		
		
	}	
	
}