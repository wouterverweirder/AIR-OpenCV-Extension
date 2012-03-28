package be.aboutme.nativeExtensions.opencv.demos
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.SegmentMaterial;
	import away3d.primitives.CubeGeometry;
	
	import be.aboutme.nativeExtensions.opencv.OpenCV;
	import be.aboutme.nativeExtensions.opencv.events.DetectionEvent;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.media.Camera;
	import flash.media.Video;

	public class VirtualWindowDemo extends DemoBase
	{
		private static const IMAGE_SIZE:Point = new Point(640, 480);
		
		private var openCV:OpenCV;
		private var minSize:Point;
		private var webcam:Camera;
		private var video:Video;
		private var bmpData:BitmapData;
		private var rectangleContainer:Sprite;
		
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		private var zeroPoint:Vector3D = new Vector3D();
		
		override protected function startDemoImplementation():void
		{
			openCV = new OpenCV();
			minSize = new Point(50, 50);
			
			//setup camera
			webcam = Camera.getCamera();
			webcam.setMode(IMAGE_SIZE.x, IMAGE_SIZE.y, 30);
			video = new Video(IMAGE_SIZE.x, IMAGE_SIZE.y);
			video.attachCamera(webcam);
			
			//create bitmapdata
			bmpData = new BitmapData(IMAGE_SIZE.x, IMAGE_SIZE.y, true, 0);
			//addChild(new Bitmap(bmpData));
			
			//create container for rectangles
			rectangleContainer = new Sprite();
			//addChild(rectangleContainer);
			
			//create away3D scene
			createScene();
			
			//add event listeners
			openCV.addEventListener(DetectionEvent.DETECTION_UPDATE, detectionUpdateHandler, false, 0, true);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			
			//load the cascade
			openCV.loadCascade(File.applicationDirectory.resolvePath("assets/haarcascades/haarcascade_frontalface_alt2.xml").nativePath);
		}
		
		private function createScene():void
		{
			scene = new Scene3D();
			camera = new Camera3D();
			camera.lookAt(zeroPoint);
			
			view = new View3D();
			view.antiAlias = 4;
			view.backgroundColor = 0xEEEEEE;
			view.scene = scene;
			view.camera = camera;
			addChild(view);
			
			var m:ColorMaterial = new ColorMaterial(0xFF0000);
			
			var i:int;
			var line:Mesh;
			//top
			for(i = -10; i < 10; i++)
			{
				line = new Mesh(new CubeGeometry(1, 1, 1000), m);
				line.x = i * 50;
				line.y = 400;
				line.z = -500;
				scene.addChild(line);
			}
			//bottom
			for(i = -10; i < 10; i++)
			{
				line = new Mesh(new CubeGeometry(1, 1, 1000), m);
				line.x = i * 50;
				line.y = -400;
				line.z = -500;
				scene.addChild(line);
			}
			//left
			for(i = -8; i < 8; i++)
			{
				line = new Mesh(new CubeGeometry(1, 1, 1000), m);
				line.x = -500;
				line.y = i * 50;
				line.z = -500;
				scene.addChild(line);
			}
			//right
			for(i = -8; i < 8; i++)
			{
				line = new Mesh(new CubeGeometry(1, 1, 1000), m);
				line.x = 500;
				line.y = i * 50;
				line.z = -500;
				scene.addChild(line);
			}
			
			//some cubes
			var cube1:Mesh = new Mesh(new CubeGeometry(100, 100, 100), m);
			cube1.x = 50;
			cube1.y = 50;
			cube1.z = -100;
			scene.addChild(cube1);
			
			var cube2:Mesh = new Mesh(new CubeGeometry(100, 100, 100), m);
			cube2.x = -50;
			cube2.y = -50;
			cube2.z = -500;
			scene.addChild(cube2);
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			view.render();
			bmpData.draw(video);
			openCV.updateImage(bmpData, minSize);
		}
		
		override protected function stopDemoImplementation():void
		{
			openCV.removeEventListener(DetectionEvent.DETECTION_UPDATE, detectionUpdateHandler);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			view.dispose();
		}
		
		protected function detectionUpdateHandler(event:DetectionEvent):void
		{
			rectangleContainer.graphics.clear();
			rectangleContainer.graphics.lineStyle(2, 0xFF0000);
			
			if(event.rectangles.length > 0)
			{
				var r:Rectangle = event.rectangles[0];
				
				var halfWidth:Number = r.width * .5;
				var halfHeight:Number = r.height * .5;
				
				var xPos:Number = (r.x + halfWidth);
				var yPos:Number = (r.y + halfHeight);
				var sizeRatio:Number = (r.width * r.height) / (IMAGE_SIZE.x * IMAGE_SIZE.y);
				
				//sizeRatio is ratio of rect to camera image
				
				camera.x = -NumberUtils.map(xPos, halfWidth, IMAGE_SIZE.x - halfWidth, -500, 500);
				camera.y = -NumberUtils.map(yPos, halfHeight, IMAGE_SIZE.y - halfHeight, -500, 500);
				camera.z = NumberUtils.map(sizeRatio, 0, 1, -1000, 0);
				
				camera.lookAt(zeroPoint);
				
				rectangleContainer.graphics.drawCircle(xPos, yPos, 5);
				rectangleContainer.graphics.drawRect(r.x, r.y, r.width, r.height);
			}
		}
	}
}