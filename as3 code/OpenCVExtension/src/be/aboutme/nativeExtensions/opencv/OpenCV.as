package be.aboutme.nativeExtensions.opencv
{
	import be.aboutme.nativeExtensions.opencv.events.DetectionEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="detectionUpdate", type="be.aboutme.nativeExtensions.opencv.events.DetectionEvent")]
	public class OpenCV extends EventDispatcher
	{
		
		private var ctx:ExtensionContext;
		
		public function OpenCV()
		{
			ctx = ExtensionContext.createExtensionContext("be.aboutme.nativeExtensions.opencv.OpenCV", null);
			ctx.addEventListener(StatusEvent.STATUS, statusHandler, false, 0, true);
			
			NativeApplication.nativeApplication.addEventListener("exiting", exitingHandler, false, 0, true);
		}
		
		protected function exitingHandler(event:Event):void
		{
			ctx.call("dispose");
		}
		
		protected function statusHandler(event:StatusEvent):void
		{
			switch(event.code)
			{
				case "status":
					switch(event.level)
					{
						case "update":
							//rectangles have been updated
							dispatchEvent(new DetectionEvent(DetectionEvent.DETECTION_UPDATE, false, false, ctx.call("getDetectedRectangles") as Vector.<Rectangle>));
							break;
					}
					break;
			}
		}
		
		public function loadCascade(fullPath:String):void
		{
			ctx.call("loadCascade", fullPath);
		}
		
		public function updateImage(bmpData:BitmapData, minSize:Point = null, maxSize:Point = null):void
		{
			ctx.call("updateImage", bmpData, minSize, maxSize)
		}
	}
}