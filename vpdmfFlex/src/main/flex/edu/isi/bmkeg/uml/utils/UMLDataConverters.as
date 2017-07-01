package edu.isi.bmkeg.uml.utils
{
	
	import edu.isi.bmkeg.uml.model.UMLattribute;
	
	public class UMLDataConverters
	{
		
		public static function convertToString(att:UMLattribute, data:Object):String {
			if (data == null) {
				return null;
			}
					
			var type:String = att.type.baseName;
					
			var stringObj:String = null;
					
			if (type == "int") {
							
				stringObj = int(data) + "";
							
			} else if (type == "long" || type == "serial") {
							
				stringObj = Number(data) + "";
							
			} else if (type == "float") {
							
				stringObj = Number(data) + "";
							
			} else if (type == "double") {
							
				stringObj = Number(data) + "";
						
			} else if (type == "boolean") {
							
				/**
				 * @todo MySQL does support full 'BOOLEAN' type at this moment.
				 * 
				 *       Current solution : A value of zero is considered false;
				 *       Non-zero values are considered true. This needs to be
				 *       updated when the 'BOOLEAN' type handling is introduced
				 *       in the future.
				 */
				// stringObj = ((Boolean) data).toString();
				if (Boolean(data)) {
					stringObj = "1";
				} else {
					stringObj = "0";
				}
							
			} else if (type == "short") {
							
				stringObj = Number(data) + "";
							
			} else if (type == "char") {
							
				stringObj = String(data).substring(0, 1);
							
			} else if (type == "url" || type== "longString") {
							
				stringObj = String(data);
							
			} else if (type == "shortString" ) {
							
				stringObj = String(data);
				if( stringObj.length >25) 
					stringObj = stringObj.substring(0,25);
							
			} else if (type == "String") {
							
				stringObj = String(data);
				if( stringObj.length > 255) 
					stringObj = stringObj.substring(0,255);
							
			} else if (type == "blob") {
							
				stringObj = "BLOB: " + data;
							
			} else if (type == "image") {
							
				stringObj = "IMAGE: " + data;
							
			} else if (type == "date" || type == "year"
				|| type == "time" || type == "timestamp") {
							
/*				SimpleDateFormat df = null;
				ParsePosition pos = null;
				Date data_date = null;
							
				if (type == "timestamp")) {
					df = new SimpleDateFormat("yyyyMMddHHmmss");
				} else if (type == "time")) {
					df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				} else if (type == "date")) {
					df = new SimpleDateFormat("yyyy-MM-dd");
				} else if (type == "year")) {
					df = new SimpleDateFormat("yyyy");
				}
							
				stringObj = df.format(data);*/
							
			} else {
							
				throw new Error("Data type " + type + " not supported");
							
			}
						
					
			return stringObj;
					
		}
								
		public static function convertToType(att:UMLattribute, data:String):Object {
					
			if (data == null) {
				return null;
			} else if (data.length == 0) {
				return null;
			}
					
			var type:String = att.type.baseName;
			var data_obj:Object = null;
					
			if (type == "int") {
						
				data = data.replace("\\s+", "");
				var data_int:int = int(data);
				data_obj = Object( data_int );
						
			} else if (type == "long" || type == "serial" || type == "float" 
				|| type == "short" || type == "double" ) {
						
				var data_long:Number = Number(data);
				data_obj = Object( data_long );
						
			} else if (type == "boolean") {
						
				var data_boolean:Boolean = Boolean(data);
				data_obj = Object( data_boolean );
						
			} else if (type == "char") {
						
				data_obj = Object( data.substring(0, 1) ) ;
						
			} else if (type == "longString" || type.substr(0,3) == "url" ) {
						
				data_obj = Object( String(data));
						
			} else if (type == "shortString") {
						
				var s:String = String(data);
				if( s.length > 25) 
					s = s.substring(0,25);
					data_obj = Object( s );
						
			} else if (type == "String") {
						
				var ss:String = String(data);
				if( ss.length > 255) 
					ss = s.substring(0,255);
				data_obj = Object( s );
						
			} else if (type == "date" || type == "year" || type == "time"
				|| type == "timestamp") {
		/*				
				SimpleDateFormat df = null;
				ParsePosition pos = null;
				Date data_date = null;
				
				if (type == "timestamp")) {
					df = new SimpleDateFormat("yyyyMMddHHmmss");
				} else if (type == "time")) {
					df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				} else if (type == "date")) {
					df = new SimpleDateFormat("yyyy-MM-dd");
				} else if (type == "year")) {
					df = new SimpleDateFormat("yyyy");
				}
						
				pos = new ParsePosition(0);
				data_date = df.parse(data, pos);
						
				if (data_date == null) {
					throw new Exception("String cannot be parsed as date");
				}
						
				data_obj = (Object) data_date;
				*/
			
			} else {
						
				throw new Error("Data type " + type + " not supported");
						
			}
					
			return data_obj;
					
		}
				
		public static function getQuote(a:UMLattribute):String {
			var type:String = a.type.baseName;
					
			var quote:String  = "";
					
			if( type == "char" || type == "String" || type == "url" ||
					type == "longString" || type == "shortString" || type == "date" ||
					type == "year" || type == "time" ||	type == "timestamp" || 
					type == "longString") {
						
				quote = "'";
						
			}
					
			return( quote );
					
		}
			
	}

}