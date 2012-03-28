package be.aboutme.nativeExtensions.opencv.demos
{
	import be.aboutme.nativeExtensions.opencv.OpenCV;
	import be.aboutme.nativeExtensions.opencv.events.DetectionEvent;
	
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Slider;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.FileFilter;
	
	public class BasicDemo extends DemoBase
	{
		private var openCV:OpenCV;
		private var camera:Camera;
		private var video:Video;
		private var rectangleView:RectangleView;
		private var bmpData:BitmapData;
		
		private var cascadeFile:File;
		
		private var minSize:Point;
		private var maxSize:Point;
		
		private var haarInput:InputText;
		private var minSizeSlider:Slider;
		private var maxSizeSlider:Slider;
		
		private static const IMAGE_SIZE:Point = new Point(640, 480);
		
		override protected function startDemoImplementation():void
		{
			//instantiate OpenCV extension
			openCV = new OpenCV();
			
			//set default sizes
			minSize = new Point(50, 50);
			maxSize = new Point(IMAGE_SIZE.y, IMAGE_SIZE.y);
			
			//setup camera
			camera = Camera.getCamera();
			camera.setMode(IMAGE_SIZE.x, IMAGE_SIZE.y, 30);
			video = new Video(IMAGE_SIZE.x, IMAGE_SIZE.y);
			video.attachCamera(camera);
			
			//create bitmapdata
			bmpData = new BitmapData(IMAGE_SIZE.x, IMAGE_SIZE.y, true, 0);
			addChild(new Bitmap(bmpData));
			
			//create haar cascade loader
			new Label(this, IMAGE_SIZE.x + 10, 10, "Haarcascade file:");
			haarInput = new InputText(this, IMAGE_SIZE.x + 110, 10);
			haarInput.enabled = false;
			new PushButton(this, IMAGE_SIZE.x + 110, 30, "Load...", loadFileClickHandler);
			
			//create sliders
			new Label(this, IMAGE_SIZE.x + 10, 60, "Minimum Size:");
			minSizeSlider = new Slider(Slider.HORIZONTAL, this, IMAGE_SIZE.x + 110, 60, minSizeChangeHandler);
			minSizeSlider.maximum = IMAGE_SIZE.y;
			minSizeSlider.value = minSize.x;
			
			new Label(this, IMAGE_SIZE.x + 10, 80, "Maximum Size:");
			maxSizeSlider = new Slider(Slider.HORIZONTAL, this, IMAGE_SIZE.x + 110, 80, maxSizeChangeHandler);
			maxSizeSlider.maximum = IMAGE_SIZE.y;
			maxSizeSlider.value = maxSize.x;
			
			//create rectangle view
			rectangleView = new RectangleView();
			rectangleView.visible = false;
			addChild(rectangleView);
			
			openCV.addEventListener(DetectionEvent.DETECTION_UPDATE, detectionUpdateHandler, false, 0, true);
			
			//enter frame loop
			addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
		}
		
		override protected function stopDemoImplementation():void
		{
			openCV.removeEventListener(DetectionEvent.DETECTION_UPDATE, detectionUpdateHandler);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function detectionUpdateHandler(event:DetectionEvent):void
		{
			if(event.rectangles.length > 0)
			{
				rectangleView.visible = true;
				if(isNaN(rectangleView.width))
				{
					rectangleView.x = event.rectangles[0].x;
					rectangleView.y = event.rectangles[0].y;
					rectangleView.width = event.rectangles[0].width;
					rectangleView.height = event.rectangles[0].height;
				}
				else
				{
					rectangleView.x += (event.rectangles[0].x - rectangleView.x) * .75;
					rectangleView.y += (event.rectangles[0].y - rectangleView.y) * .75;
					rectangleView.width += (event.rectangles[0].width - rectangleView.width) * .75;
					rectangleView.height += (event.rectangles[0].height - rectangleView.height) * .75;
				}
			}
			else
			{
				rectangleView.visible = false;
			}
		}
		
		private function loadFileClickHandler(event:Event):void
		{
			cascadeFile = File.applicationDirectory;
			cascadeFile.addEventListener(Event.SELECT, cascadeFileSelectHandler, false, 0, true);
			cascadeFile.browseForOpen("Haarcascade File", [new FileFilter("XML File", "*.xml", "*.xml")]);
		}
		
		protected function cascadeFileSelectHandler(event:Event):void
		{
			haarInput.text = cascadeFile.nativePath;
			openCV.loadCascade(cascadeFile.nativePath);
		}
		
		private function minSizeChangeHandler(event:Event):void
		{
			minSize.x = minSize.y = uint(minSizeSlider.value);
		}
		
		private function maxSizeChangeHandler(event:Event):void
		{
			maxSize.x = maxSize.y = uint(maxSizeSlider.value);
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			bmpData.draw(video);
			openCV.updateImage(bmpData, minSize, maxSize);
		}
	}
}