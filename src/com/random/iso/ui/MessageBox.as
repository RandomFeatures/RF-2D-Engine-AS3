package com.random.iso.ui 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import com.random.iso.ui.aleButton;
	import flash.events.Event;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.random.game.consts.StaticResources;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class MessageBox
	{
		protected var m_Visible:Boolean = false;
		protected var m_LabelText:FlxText;
		protected var m_BackGround:FlxSprite;
		protected var m_Fading:Boolean = false;
		protected var m_Delay:Number = 0.25;
				
		private var _tweenX : Tween;
		private var _tweenY : Tween;
		private var m_useArrow:Boolean = false;
		protected var m_HelpArrow:MovieClip;
		private var m_ArrorIndex:int = 1;
		
		public function MessageBox(font:String = null, align:String ="left") 
		{
			m_LabelText = new FlxText(100, 100, 325, "                                                                                                        ");
			m_LabelText.alignment = align
			m_LabelText.font = font;
			m_LabelText.size = 18;
			m_LabelText.color = 0x00000000;
			m_LabelText.x = 101;
			m_LabelText.y = 250;
			
			m_BackGround = new FlxSprite(0, 0);
			
			m_HelpArrow = new MovieClip();
			var _image:Bitmap= new StaticResources.RedArrow();
			var m_pSprite:Sprite = new Sprite();               
			m_pSprite.graphics.beginBitmapFill(_image.bitmapData);
			m_pSprite.graphics.drawRect(0, 0, _image.bitmapData.width, _image.bitmapData.height);
			m_pSprite.graphics.endFill();

			m_HelpArrow.name = "HelperArrow";
			m_HelpArrow.addChild(m_pSprite);
			m_HelpArrow.visible =  false;

		}
		
	
		
		public function get Visible():Boolean { return m_Visible; }
		
		public function set BackGround(value:FlxSprite):void {
			m_BackGround = value;
		}
		public function get BackGround():FlxSprite {
			return m_BackGround;
		}

		public function get TextLabel():FlxText {
			return m_LabelText;
		}
		
		virtual public function show():void {
			if (m_useArrow) {
				FlxG.state.addChildAt(m_HelpArrow, m_ArrorIndex);
				
				m_HelpArrow.visible = true;
			}
		}
		
		protected function setMessage(msg:String):void {
			m_LabelText.text = msg;
			m_LabelText.update();
			m_Visible = true;
		}

		virtual public function hide():void {
			m_Visible = false;
			if (m_useArrow)
			{
				m_HelpArrow.visible = false;
				if (FlxG.state.parent.stage.getChildByName("HelperArrow"))
				{
					FlxG.state.parent.stage.removeChild(FlxG.state.parent.stage.getChildByName("HelperArrow"));
				}
			}
		}

		virtual public function render():void {
			//not visible so who cares
			if (!m_Visible) return;
			m_BackGround.render();
			m_LabelText.render();
			fading();
		}
		
		protected function fadeAway(delay:Number ):void
		{
			m_Delay = delay;
			m_Fading = true;
			if (m_useArrow)
				m_HelpArrow.visible = false;
		}
		
		//update the image animation
		virtual public function fading():void
		{
			if (m_Fading)
			{
				var fade:Number;
				fade = FlxG.elapsed / m_Delay;
				
				m_LabelText.alpha -= fade;
				m_BackGround.alpha -= fade;
				
				if(m_LabelText.alpha <= 0)
				{
					m_LabelText.alpha = 0;
				}
				if(m_BackGround.alpha <= 0)
				{
					m_BackGround.alpha = 0;
				}
				m_Fading  = false;
			}
		}
		
		virtual public function MouseClick(x:int, y:int):Boolean {
			return false;
		}
		
		virtual public function MouseMove(x:int, y:int):Boolean
		{
			if (!m_Visible) return false;
			if (m_Visible) return true;
			
			return false
		}
		
		virtual public function setPosition(posx:int, posy:int):void {
			m_BackGround.x = posx;
			m_BackGround.y = posy;
			m_LabelText.x = posx + 40;
			m_LabelText.y = posy + 60;
			m_LabelText.update();
		}
		
		public function setHelpArrow(x:int, y:int, rot:Number, bAnimate:Boolean=false, iIndx:int=1):void {
			m_HelpArrow.x = x - (m_HelpArrow.width/2); // reference point is center
			m_HelpArrow.y = y;
			m_HelpArrow.rotation = rot;
			m_useArrow = true;
			m_ArrorIndex = iIndx;
			if (bAnimate) {
				
				if (rot == 90 || rot == -90){
					_tweenX = new Tween(m_HelpArrow, "x", Regular.easeInOut, m_HelpArrow.x, m_HelpArrow.x-20, 16, false);
					_tweenX.addEventListener(TweenEvent.MOTION_FINISH, onTweenDone);			
					_tweenX.start();
					if (_tweenY)
						_tweenY.stop();
				}else {
					_tweenY = new Tween(m_HelpArrow, "y", Regular.easeInOut, m_HelpArrow.y, m_HelpArrow.y-20, 16, false);
					_tweenY.addEventListener(TweenEvent.MOTION_FINISH, onTweenDone);			
					_tweenY.start();
					if (_tweenX)
						_tweenX.stop();
				}
				/*
				if (rot == 90 || rot == -90) {
					_tweenY = new Tween(m_HelpArrow, "y", Regular.easeInOut, m_HelpArrow.y, m_HelpArrow.y-20, 16, false);
					_tweenY.addEventListener(TweenEvent.MOTION_FINISH, onTweenDone);			
					_tweenY.start();
					if (_tweenX)
						_tweenX.stop();
				}
				if (rot == 180 || rot == -180 || rot == 0) {
					_tweenX = new Tween(m_HelpArrow, "x", Regular.easeInOut, m_HelpArrow.x, m_HelpArrow.x-20, 16, false);
					_tweenX.addEventListener(TweenEvent.MOTION_FINISH, onTweenDone);			
					_tweenX.start();
					if (_tweenY)
						_tweenY.stop();
				}
				*/
			}
		}
		
		private function onTweenDone(event:Event):void {
			if (event.target == _tweenX)
				_tweenX.yoyo();
			if (event.target == _tweenY)
				_tweenY.yoyo();
		}
		
	}

}