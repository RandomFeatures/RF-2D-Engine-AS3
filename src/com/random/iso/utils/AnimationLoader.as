package com.random.iso.utils 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import com.random.game.state.Adventure;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class AnimationLoader extends EventDispatcher{
		
		public static const DONE:String = "done";
		
		private var m_SpriteImage:Bitmap;
		
		private var m_Loader:Loader;
		private var m_Loaded:Boolean = false;
		private var m_FileName:String;
		private var m_Unique:Boolean;
		
		public function AnimationLoader() {
			
		}
		
		public function get FileName():String { return m_FileName; }
		public function get Unique():Boolean { return m_Unique; }
		/**
		 * Load an Image from the webserver
		 * @param	URL of the image file to load
		 * 
		 */
		public function loadFile(url:String, unique:Boolean ):void {
			m_FileName = url;
			m_Unique = unique;
			m_Loader = new Loader();
			m_Loader.load(new URLRequest(url));
			m_Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFileLoadComplete);
		
		}
		//Event for when the image is loaded
		private function onFileLoadComplete(e:Event):void {
			
			process();
			m_Loaded = true;
			dispatchEvent(new Event(DONE));
		}
		//get a reference to the image and notify any linsteners that it is ready
		private function process():void{
			//get the spritesheet from the loader
			m_SpriteImage = m_Loader.content as Bitmap;
			//m_Loader.close();
			m_Loader.unload();
			//ditch the event listeners
			m_Loader.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			m_Loader = null;
		}
		
		
		public function get SpriteImage():Bitmap { return m_SpriteImage; }
		public function set SpriteImage(value:Bitmap):void { m_SpriteImage = value;	}
		public function get Loaded():Boolean { return m_Loaded; }
		
	}
}