package com.random.game.UI 
{
	import org.flixel.FlxLoadSprite;
	import com.random.game.consts.RealmConsts;
	import com.random.iso.utils.AnimationLoader;
	import flash.events.Event;
	import com.random.game.consts.Globals;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class TagIcons extends FlxLoadSprite
	{
		
		private var m_ImageLoader:AnimationLoader;
		private var m_xOffSet:int = 0;
		private var m_yOffSet:int = 0;
		private var m_FileName:String = "";
		private var m_Protected:Boolean = true;
		public function TagIcons() {
			
		}
		
		public function loadImage(url:String):void {
			//Use the AnimationLoader to get the image from the server
			if (url != "")
			{
				m_FileName = url;
				m_ImageLoader = new AnimationLoader();
				m_ImageLoader.addEventListener(AnimationLoader.DONE, onImageDoneLoading);
				m_ImageLoader.loadFile(Globals.RESOURCE_BASE + url, true);
				
			}
		}

		//The image has downloaded from the sever
		private function onImageDoneLoading(e:Event):void {
			loadExtGraphic(m_ImageLoader.SpriteImage, m_FileName, m_Protected, false, false, 0, 0, m_ImageLoader.Unique );
			m_ImageLoader.removeEventListener(AnimationLoader.DONE, onImageDoneLoading);	
			m_ImageLoader = null;
		}
		
		
		//figure out the objects 2d screen pos based on the tile it cupies
		public function setPosition(posx:int, posy:int):void
		{
			this.x = posx;
			this.y = posy;
		}
		
	}

}