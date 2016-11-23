package com.random.iso.characters.animation
{

	import com.random.iso.utils.AnimationLoader;
	import com.random.iso.consts.*;
	import flash.display.BlendMode;
	import org.flixel.FlxLoadSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class AniSprite extends FlxLoadSprite
	{
		
		public static const DONE:String = "done";
		
		private var m_DoneLoading:Boolean;
		private var m_Playing:Boolean;
		private var m_AnimationLoader:AnimationLoader;
		private var m_Animated:Boolean=false;
		private var m_Width:uint=0;
		private var m_Height:uint = 0;
		private var m_NotUsed:Boolean = false;
		private var m_Type:String;
		private var m_Url:String = "";
		
		public function get LayerUsed():Boolean { return !m_NotUsed; }
		public function get DoneLoading():Boolean { return m_DoneLoading; }
		public function get Playing():Boolean { return m_Playing; }
		public function get Height():int { return m_Height; }
		public function get Width():int { return m_Width; }
		
		
		public function AniSprite(X:Number,Y:Number, type:String = ObjTypes.CHAR):void
		{
			super(X, Y);
			m_Type = type;
		}
		
		public function loadLayerAnimation(url:String, Animated:Boolean = false, Width:uint = 0, Height:uint = 0):void {
			
			m_Animated = Animated;
			m_Width = Width;
			m_Height = Height;
			m_Playing = false;
			m_Url = url;
			//Use the AnimationLoader to get the image from the server
			if (m_Url.length > 0)
			{
				m_NotUsed = false;
				m_AnimationLoader = new AnimationLoader();
				m_AnimationLoader.addEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
				m_AnimationLoader.loadFile(GameConstants.RESOURCE_BASE + m_Url, false);
			}else
			{
				m_NotUsed = true;
				m_DoneLoading = true;
				dispatchEvent(new Event(DONE));
			}
			
		}
		
		
		public function checkLoaded(url:String):Boolean {
			
			//if (m_Url.length == 0)
			//	return false;
			//else
			//{
				return m_Url == url;
			//}
		}
		//The image has downloaded from the sever
		private function onAnimationDoneLoading(e:Event):void {
			m_AnimationLoader.removeEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
			loadExtGraphic(m_AnimationLoader.SpriteImage, m_Url, true, true, false, m_Width, m_Height, true);
			calcFrame();//forces teh colors to draw
			
			dispatchEvent(new Event(DONE));
			m_DoneLoading = true;
			m_AnimationLoader.removeEventListener(AnimationLoader.DONE, onAnimationDoneLoading);	
			m_AnimationLoader = null;
		}
		
		public function forceUpdate():void {
			calcFrame();
		}
		
		public function AvatarAnimations(Looped:Boolean=true):void
		{
			
			this.addAnimation(IsoConstants.DIR_SE, [0,1,2,3,4,5,6,7], 8, Looped);
			//this.addAnimation("SS", [8,9,10,11,12,13,14,15], 8, Looped);
			this.addAnimation(IsoConstants.DIR_SW, [16,17,18,19,20,21,22,23], 8, Looped);
			//this.addAnimation("WW", [24,25,26,27,28,29,30,31], 8, Looped);
			this.addAnimation(IsoConstants.DIR_NW, [32,33,34,35,36,37,38,39], 8, Looped);
			//this.addAnimation("NN", [40,41,42,43,44,45,46,47], 8, Looped);
			this.addAnimation(IsoConstants.DIR_NE, [48,49,50,51,52,53,54,55], 8, Looped);
			//this.addAnimation("EE", [56,57,58,59,60,61,62,63], 8, Looped);
		}
		

		public function fourFrameAnimations(framerate:Number, looped:Boolean=true):void
		{
			this.addAnimation(IsoConstants.DIR_SE, [0,1,2,3], framerate, looped);
			this.addAnimation(IsoConstants.DIR_SW, [4,5,6,7], framerate, looped);
			this.addAnimation(IsoConstants.DIR_NW, [8,9,10,11], framerate, looped);
			this.addAnimation(IsoConstants.DIR_NE, [12,13,14,15], framerate, looped);
		}
		
		public function fourFramePingPong(framerate:Number, looped:Boolean=true):void
		{
			this.addAnimation(IsoConstants.DIR_SE, [0,1,2,3,2,1], framerate, looped);
			this.addAnimation(IsoConstants.DIR_SW, [4,5,6,7,6,5], framerate, looped);
			this.addAnimation(IsoConstants.DIR_NW, [8,9,10,11,10,9], framerate, looped);
			this.addAnimation(IsoConstants.DIR_NE, [12,13,14,15,14,13], framerate, looped);
		}
		
		public function eightFrameAnimations(framerate:Number, looped:Boolean=true):void
		{
			
			this.addAnimation(IsoConstants.DIR_SE, [0,1,2,3,4,5,6,7], framerate, looped);
			this.addAnimation(IsoConstants.DIR_SW, [8,9,10,11,12,13,14,15], framerate, looped);
			this.addAnimation(IsoConstants.DIR_NW, [16,17,18,19,20,21,22,23], framerate, looped);
			this.addAnimation(IsoConstants.DIR_NE, [24,25,26,27,28,29,30,31], framerate, looped);
		}
		
		public function defaultAnimations(Looped:Boolean=true):void
		{
			this.addAnimation(IsoConstants.DEFAULT, [0,1,2,3,4,5,6,7], 10, Looped);
		}
		
		//load walksheet
		//setup animations
		//play animations
		//override update
		//override render
		
		
		
		
		
		
	}

}