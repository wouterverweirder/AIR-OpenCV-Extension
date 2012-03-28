package
{
	import be.aboutme.nativeExtensions.opencv.demos.BasicDemo;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import net.hires.debug.Stats;
	
	[SWF(frameRate="60", width="1024", height="768")]
	public class OpenCVExtensionDemo extends Sprite
	{
		
		public function OpenCVExtensionDemo()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.nativeWindow.visible = true;
			stage.addChild(new Stats());
			
			addChild(new BasicDemo());
		}
	}
}