package edu.isi.bmkeg.lapdftextModule.model
{
	import flash.display.Bitmap;
	
	import mx.collections.ArrayCollection;
	
	import spark.primitives.*;

	public class LapdftextBlockHolder extends Object
	{

		[Bindable]
		public var image:Bitmap;

		[Bindable]
		public var alpha:Number = 1.0;

		[Bindable]
		public var state:int = 0;

		[Bindable]
		public var pdfScale:Number;

		[Bindable]
		public var page:int;

		[Bindable]
		public var extraRectangles:ArrayCollection = new ArrayCollection();
				
		public function LapdftextBlockHolder(pdfScale:Number)
		{
			super();
			this.pdfScale = pdfScale;
		}
		
	}
	
}