package edu.isi.bmkeg.utils.dao
{
	import mx.core.FlexGlobals;
	import mx.utils.URLUtil;
	
	import spark.components.Application;

	public class Utils
	{
		
		private static const AMF_CHANNEL_PATH:String = "messagebroker/amf";

		/**
		 * Returns the url from which this application was loaded.
		 * 
		 */
		public static function getAppUrl():String {
			return Application(FlexGlobals.topLevelApplication).url;
		}
		
		/**
		 *  Returns the WebApplication context (i.e., the first segment of the url path)
		 *  which is extracted from the Application's Url
		 */ 
		public static function getWebAppContext():String {
			var url:String = getAppUrl();
			var prot:String = URLUtil.getProtocol(url);
			var server:String = URLUtil.getServerNameWithPort(url);
			var protAndServer:String = prot + "://"+server + "/";
			if (url.substr(0,protAndServer.length) != protAndServer)
				return null;
			var path:String = url.substr(protAndServer.length);
			var p:int = path.indexOf("/");
			if (p <0)
				return null;
			return path.substr(0,p);			
		} 
		
		/**
		 *  Returns the Protocol and server
		 */ 
		public static function getServerProt():String {
			var url:String = getAppUrl();
			var prot:String = URLUtil.getProtocol(url);
			var server:String = URLUtil.getServerNameWithPort(url);
			var protAndServer:String = prot + "://"+server + "/";
			if (url.substr(0,protAndServer.length) != protAndServer)
				return null;
			return protAndServer;			
		} 
		
		public static function getRemotingEndpoint():String {
			return '/' + Utils.getWebAppContext() + '/' + Constants.AMF_CHANNEL_PATH
		}		
	
	}
	
}