package edu.isi.bmkeg.vpdmf.model.instances
{
	import edu.isi.bmkeg.uml.model.UMLattribute;
	import edu.isi.bmkeg.uml.model.UMLclass;
	import edu.isi.bmkeg.uml.utils.UMLDataConverters;
	import edu.isi.bmkeg.vpdmf.model.instances.ClassInstance;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.vpdmf.model.instances.AttributeInstance")]
	public class AttributeInstance
	{
		public function AttributeInstance(){}

		public var _value:Object;
		public var definition:UMLattribute;
		public var defName:String;
		public var isNotNull:Boolean;
		public var connectedKeys:ArrayCollection = new ArrayCollection();
		public var object:ClassInstance;
		
		public function init(attDef:UMLattribute):void {
		
			this.definition = attDef;
			this.defName = attDef.baseName;
			
		}
		
		public function connectTo(that:AttributeInstance): void {
			
			this.connectedKeys.addItem(that);
			that.connectedKeys.addItem(this);
			
		}
		
		public function writeValueString(value:String):void {

			var data:Object = UMLDataConverters.convertToType(this.definition, value);
			this._value = data;
				
		}
		
		public function readValueString():String {
			return UMLDataConverters.convertToString(this.definition, this._value);
		}
		
		public function set value(value:Object):void {
			this._value = value;
			
			for each (var ai:AttributeInstance in this.connectedKeys) {			
				if (ai != this) {
					ai._value = value;
				}
			}
			
		}

		public function get value():Object {
			return this._value;
		}
		
		public function removeDefinition():void {
			
			this.definition = null;
			for each (var ai:AttributeInstance in this.connectedKeys) {			
				ai.definition = null;
			}
			
		}

		
	}
}