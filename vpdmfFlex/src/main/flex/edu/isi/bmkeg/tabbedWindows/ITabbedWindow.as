package edu.isi.bmkeg.tabbedWindows
{
	import mx.core.Container;

	/**
	 * Interface that defines advanced features for Containers used as Tabbed Windows.
	 * Note: To declare an interface implementation in a MXML component use the "implements"
	 * attribute,
	 */
	public interface ITabbedWindow
	{
		/**
		 * Creates a new Container thar represents a duplicate of this tabbed window
		 * It is called by the tabbed windows manager as a response to GUI requests for
		 * duplicating a tabbed window (e.g., when a tabbed window is dragged and dropped 
		 * while holding down the [Ctrl] (or [Command] in Mac).
		 */
		function duplicateWindow():Container;
		
	}
}