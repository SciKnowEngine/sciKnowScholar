package edu.isi.bmkeg.utils.serverUpdates.services.serverInteraction.impl
{

	import mx.collections.ArrayCollection;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import mx.rpc.AbstractOperation;

	import edu.isi.bmkeg.utils.dao.Utils;
	import edu.isi.bmkeg.utils.serverUpdates.services.serverInteraction.*;

	public class ServerUpdateServerImpl 
			extends RemoteObject 
			implements IServerUpdateServer
	{

		private static const SERVICES_DEST:String = "serverUpdates";

		public function ServerUpdateServerImpl()
		{
			destination = SERVICES_DEST;
			endpoint = Utils.getRemotingEndpoint();
			showBusyCursor = false;
		}
		
		// ~~~~~~~~~~~~~~~
		// functions
		// ~~~~~~~~~~~~~~~
		public function get send():AbstractOperation
		{
			return getOperation("send");
		}

	}

}