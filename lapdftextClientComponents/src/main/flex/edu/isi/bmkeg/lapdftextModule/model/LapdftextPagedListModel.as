package edu.isi.bmkeg.lapdftextModule.model
{
	import edu.isi.bmkeg.pagedList.model.PagedListModel;
	
	public class LapdftextPagedListModel extends PagedListModel
	{
		
		public static var LIST_ID:String = "lapdftextCorpusList"

		public function LapdftextPagedListModel()
		{
			super();
			this.id = LIST_ID;
		}
	}
}