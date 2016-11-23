package com.random.game.UI 
{
	import org.flixel.FlxLoadSprite;
	import consts.RealmConsts;
	import com.random.iso.utils.AnimationLoader;
	import flash.events.Event;
	import consts.Globals;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class DungeonEditorBG extends FlxLoadSprite
	{
		private var m_ImageLoader:AnimationLoader;
		private var m_Protected:Boolean = false;
		private var m_FileName:String = "";
		
		public function loadImage(url:String):void {
			//Use the AnimationLoader to get the image from the server
			if (url != "")
			{
				m_FileName = url;
				m_ImageLoader = new AnimationLoader();
				m_ImageLoader.addEventListener(AnimationLoader.DONE, onImageDoneLoading);
				m_ImageLoader.loadFile(Globals.RESOURCE_BASE + url, false);
				
			}
		}

		//The image has downloaded from the sever
		private function onImageDoneLoading(e:Event):void {
			loadExtGraphic(m_ImageLoader.SpriteImage, m_FileName, m_Protected, false, false, 0, 0, true);
			m_ImageLoader.removeEventListener(AnimationLoader.DONE, onImageDoneLoading);	
			m_ImageLoader = null;
		}
		
	}

}