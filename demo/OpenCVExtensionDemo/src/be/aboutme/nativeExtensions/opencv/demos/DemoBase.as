package be.aboutme.nativeExtensions.opencv.demos
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class DemoBase extends Sprite
	{
		
		protected var demoStarted:Boolean;
		protected var explicitWidth:Number = 800;
		protected var explicitHeight:Number = 600;
		
		public function DemoBase()
		{
			demoStarted = false;
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			startDemo();
		}
		
		private function removedFromStageHandler(event:Event):void
		{
			stopDemo();
		}
		
		public function startDemo():void
		{
			if(!demoStarted)
			{
				demoStarted = true;
				startDemoImplementation();
				layout();
			}
		}
		
		public function stopDemo():void
		{
			if(demoStarted)
			{
				demoStarted = false;
				stopDemoImplementation();
			}
		}
		
		protected function startDemoImplementation():void
		{
		}
		
		protected function stopDemoImplementation():void
		{
		}
		
		public function setSize(width:Number, height:Number):void
		{
			explicitWidth = width;
			explicitHeight = height;
			layout();
		}
		
		protected function layout():void
		{
		}
	}
}