package be.aboutme.nativeExtensions.opencv.events
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class DetectionEvent extends Event
	{
		
		public static const DETECTION_UPDATE:String = "detectionUpdate";
		
		public var rectangles:Vector.<Rectangle>;
		
		public function DetectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, rectangles:Vector.<Rectangle> = null)
		{
			super(type, bubbles, cancelable);
			this.rectangles = rectangles;
		}
		
		override public function clone():Event
		{
			return new DetectionEvent(type, bubbles, cancelable, rectangles);
		}
	}
}