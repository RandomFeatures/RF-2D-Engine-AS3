package com.random.iso.map 
{
	import flash.xml.XMLNode;
	import org.flixel.FlxLoadSprite;
	import com.random.iso.utils.AnimationLoader;
	import com.random.iso.consts.GameConstants;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import com.random.iso.consts.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import com.random.game.UI.MsgBoxManager;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class IsoFloorImage extends IsoStructure
	{
		private var m_Width:uint=0;
		private var m_Height:uint = 0;
		private var m_Ready:Boolean = false;
		private var m_Notused:Boolean = false;
		private var m_Nitmap:Bitmap;
		private var m_xOffset:int;
		private var m_yOffset:int;
		private var m_ImageLoader:AnimationLoader;
		private var m_LoadingXML:Boolean;
		private var m_Map:IsoMap;
		private var m_FileName:String;
		protected var m_XmlData:String;
		
		public function IsoFloorImage(map:IsoMap) 
		{
		    super();
			m_Map = map;
		}
		
		public function get Ready():Boolean { return m_Ready; }
		public function get xOffset():int { return m_xOffset; }
		public function set xOffset( value:int ):void { m_xOffset = value; };
		public function get yOffset():int { return m_yOffset; }
		public function set yOffset( value:int ):void { m_yOffset = value; };
		
		
		public function loadFromURL(file:String):void
		{
			var xmlLoader:URLLoader = new URLLoader();
			
			m_LoadingXML = true;
			xmlLoader.addEventListener(Event.COMPLETE, onLoadXML);
			xmlLoader.load(new URLRequest(GameConstants.RESOURCE_BASE+file));
		}
		
		public function onLoadXML(e:Event):void {
			loadFromXML( new XML(e.target.data) );			
		}	
		
		
		public function loadFromXML(xml:XML):void
		{
			
			m_XmlData = xml.objects.Floor;
			
			var imagefile:String = xml.floor.@file;
			m_xOffset = x = int(xml.floor.@x_offset);
			m_yOffset = y = int(xml.floor.@y_offset);
			loadFloorImage(imagefile);
			try {
				getEditorData(XML(xml.floor));		
			}catch(errObject:Error)
			{
			}
			
		}
		
		public function toXML():String {
			return m_XmlData.toString();
		}
		
		private function loadFloorImage(url:String):void {
			
			
			//Use the AnimationLoader to get the image from the server
			if (url != "")
			{
				m_FileName = url;
				m_ImageLoader = new AnimationLoader();
				m_ImageLoader.addEventListener(AnimationLoader.DONE, onImageDoneLoading);
				m_ImageLoader.loadFile(GameConstants.RESOURCE_BASE + url, false);
				
			}else
			{
				m_Notused = true;
				m_Ready = true;
			}
		}
		
		
		//The image has downloaded from the sever
		private function onImageDoneLoading(e:Event):void {
			loadExtGraphic(m_ImageLoader.SpriteImage, m_FileName, false, false, false,0,0,true);
			m_Ready = true;
			m_Map.flatenBackground();
			m_ImageLoader.removeEventListener(AnimationLoader.DONE, onImageDoneLoading);	
			m_ImageLoader = null;
		}
		
	}

}