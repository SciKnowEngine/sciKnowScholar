package edu.isi.bmkeg.utils.serverUpdates.services.impl
{

	import edu.isi.bmkeg.utils.dao.*;
	import edu.isi.bmkeg.utils.serverUpdates.events.*;
	import edu.isi.bmkeg.utils.serverUpdates.services.*;
	import edu.isi.bmkeg.utils.serverUpdates.services.serverInteraction.*;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Actor;

	public class ServerUpdateServiceImpl extends Actor implements IServerUpdateService {

		private var _server:IServerUpdateServer;

		[Inject]
		public function get server():IServerUpdateServer

		{
			return _server;
		}

		public function set server(s:IServerUpdateServer):void
		{
			_server = s;
			initServer();
		}
		
		private function initServer():void
		{
			if (_server is AbstractService)
			{
				AbstractService(_server).addEventListener(FaultEvent.FAULT,faultHandler);
			}

			_server.send.addEventListener(ResultEvent.RESULT, messageResultHandler);
			_server.send.addEventListener(FaultEvent.FAULT, faultHandler);

		}

		private function asyncResponderFailHandler(fail:Object, token:Object):void
		{
			faultHandler(fail as FaultEvent);
		}

		private function faultHandler(event:FaultEvent):void
		{
			dispatch(event);
		}

		// ~~~~~~~~~
		// functions
		// ~~~~~~~~~
		
		private function messageResultHandler(event:ResultEvent):void {
			
			var message:String = String(event.result);
			dispatch(new ServerUpdateEvent(message));
		
		}
		
	}

}
