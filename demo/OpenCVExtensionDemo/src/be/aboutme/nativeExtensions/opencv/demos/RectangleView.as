package be.aboutme.nativeExtensions.opencv.demos
{
	import flash.display.Sprite;
	
	public class RectangleView extends Sprite
	{
		
		private var _width:Number;
		override public function get width():Number { return _width; }
		
		override public function set width(value:Number):void
		{
			if (_width == value)
				return;
			_width = value;
		}
		
		private var _height:Number;
		override public function get height():Number { return _height; }
		
		override public function set height(value:Number):void
		{
			if (_height == value)
				return;
			_height = value;
			redraw();
		}
		
		private function redraw():void
		{
			graphics.clear();
			graphics.lineStyle(4, 0xFF0000);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}		
		
		public function RectangleView()
		{
			super();
		}
	}
}