package edu.isi.bmkeg.utils.dao
{	
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="edu.isi.bmkeg.utils.dao.ReturnEnvelope")]
	public class ReturnEnvelope
	{
		public function ReturnEnvelope()
		{
		}

		public var payload:ArrayCollection;
		public var queryHitCountMax:int;
	}
	
}