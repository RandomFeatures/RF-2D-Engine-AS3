package com.random.iso.characters.monsters 
{
	import org.flixel.*
	import com.random.iso.characters.animation.AniSprite;
	import flash.events.Event;
	import com.random.iso.consts.*;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class MonsterAction extends EventDispatcher
	{
		
		public static const READY:String = "ready";
		
		
		protected var m_MonsterAction:AniSprite;

		protected var m_FrameWidth:int;
		protected var m_FrameHeight:int;
		protected var m_ImageWidth:int;
		protected var m_ImageHeight:int;
		protected var m_FrameCount:int;
		protected var m_BlendMode:int;
		protected var m_Mode:int;
		protected var m_Loaded:Boolean;
		protected var m_Dir: String;
		protected var m_Action: String;
		protected var m_LoadingLayer:Boolean = true;
		protected var m_LayersLoaded:int = 0;
		protected var m_SingleDir:Boolean = true;
		public static var m_GlowEffect:GlowFilter = null;
		protected var m_MouseOver:Boolean = false;
		protected var m_EditMode:Boolean = false;
		protected var m_FPS:Number = 10;	
		protected var m_AnimationType:String = "NONE"
		
		public function set EditMode(value:Boolean):void 
		{ 
			m_EditMode = value; 
			if(m_EditMode)
				m_GlowEffect = new GlowFilter(0x00009900);
			//else	
			//	m_GlowEffect = new GlowFilter(0x00FF0000);
			if (m_GlowEffect != null)
				m_GlowEffect.inner = true;
		}
		public function get EditMode():Boolean { return m_EditMode; }
		
		
		public function LoadActionAnimations(chrXML:XML, action:String, dir:String):void 
		{
			m_Dir = dir;
			m_Action = action;
			m_SingleDir = false;
			var urlBase:String = chrXML.action.(@name == action).@file;
			var colorBase:uint = chrXML.action.(@name == action).@color;
			m_FrameCount = chrXML.action.(@name == action).@frames;
			m_AnimationType = String(chrXML.action.@animation).toUpperCase();
			
			m_FrameWidth = int(chrXML.action.(@name == action).@width);
			m_FrameHeight = int(chrXML.action.(@name == action).@height);
			m_FPS =	chrXML.action.(@name == action).@fps;
				
			m_MonsterAction = new AniSprite(0,0,ObjTypes.MOB);
			m_MonsterAction.addEventListener(AniSprite.DONE, onBaseLoaded);
			m_MonsterAction.loadLayerAnimation(urlBase, true, m_FrameWidth, m_FrameHeight);
					
			switch(m_FrameCount)
			{
				case 4:
					m_MonsterAction.fourFramePingPong(m_FPS, true);
					break;
				case 8:
					m_MonsterAction.eightFrameAnimations(m_FPS,true)
					break;
			}
			
			m_MonsterAction.color = colorBase;
			m_LoadingLayer = false;
			
			if ((m_Action == ActionConstants.IDLE) && (m_AnimationType == "RANDOM"))
				playRandomAnimation();
			
		}
		
		private function onBaseLoaded(e:Event):void
		{
			m_MonsterAction.removeEventListener(AniSprite.DONE, onBaseLoaded);
			dispatchEvent(new Event(READY));
		}

		
		private function playRandomAnimation():void {
			
			var irow:int;
				
			switch (m_Dir)
			{
				case IsoConstants.DIR_SE:
					irow = 2;
					break;
				case IsoConstants.DIR_SW:	
					irow = 3;
					break;
				case IsoConstants.DIR_NW:	
					irow = 1;
					break;
				case IsoConstants.DIR_NE:	
					irow = 0;
					break;
			}
			
			m_MonsterAction.randomRowFrame(irow,4);
			var wait:int = (500 + (10000 - 500)) * Math.random()
			setTimeout(playRandomAnimation, wait);

		}
		
		public function loaded():Boolean {
			var rtn:Boolean;
			
			if (!m_LoadingLayer)
			{
				rtn = m_MonsterAction.DoneLoading;
			}
			else
				rtn = false;
			return rtn;
		}
		
		public function cleanUp():void 
		{
			if(m_MonsterAction) m_MonsterAction.kill();
			m_MonsterAction = null;
			
		}
		
		public function play(dir:String=""):void
		{ 
			if (dir != "")
			{
				m_Dir = dir;
			}
			if (m_MonsterAction) 
			{
				m_MonsterAction.play(m_Dir);
			}
		}
		
		
		public function screenPoint(X:int, Y:int):void
		{
			
			if (m_MonsterAction)	{
				m_MonsterAction.x = X;
				m_MonsterAction.y = Y;	
			}
		}
		
		
		public function setAlpha(a:Number):void
		{
			if (m_MonsterAction) m_MonsterAction.alpha = a;
		}
		
		public function render():void
		{
			if(m_MonsterAction)
				m_MonsterAction.render();
		}
		
		public function update():void {
			
			if(m_MonsterAction)
				m_MonsterAction.update();
		}

		public function get Dir():String { return m_Dir; }
		public function set Dir(value:String):void { m_Dir = value; }

		
		
		public function getMouseOver(x:int, y:int):Boolean
		{
			
			
			if (!m_MouseOver)
			{
				if (x > m_MonsterAction.x && x < (m_MonsterAction.x + m_MonsterAction.Width))
				{
					if (y > m_MonsterAction.y && y < (m_MonsterAction.y + m_MonsterAction.Height))
					{
						if (m_MonsterAction.pixels.hitTest(new Point(m_MonsterAction.x, m_MonsterAction.y), 0, new Point(x, y)))
						{
							m_MouseOver = true;
							onMouseOver();
							return true;
						}
					}
				}
			}else
			{
				if (x > m_MonsterAction.x && x < (m_MonsterAction.x + m_MonsterAction.Width))
				{
					if (y > m_MonsterAction.y && y < (m_MonsterAction.y + m_MonsterAction.Height))
					{
						if (m_MonsterAction.pixels.hitTest(new Point(m_MonsterAction.x, m_MonsterAction.y), 0, new Point(x, y)))
						{
							return true;
						}
					}
				}
				m_MouseOver = false;
				onMouseOut();		
				return false;
			}
			
			return false;
		}
		
		//override mouse to not dispatch events
		public function setMouseOut():void 
		{
			if (m_MouseOver)
				onMouseOut();	
			m_MouseOver = false;
		}
		
		
		//when the mouse leaves remove the glow effect
		public function onMouseOver():void {
			
			if (m_GlowEffect != null)
				m_MonsterAction.SetFilter(m_GlowEffect);
		}
		
		//when the mouse enters add the glow effect
		public function onMouseOut():void {
			if (m_GlowEffect != null)
				m_MonsterAction.RemoveFilter();
		}
		
		public function addGlowEffect(glow:GlowFilter):void
		{
			m_MonsterAction.RemoveFilter();//remove the filter if there is already one
			m_MonsterAction.SetFilter(glow);
		}
		
		public function removeGlowEffect():void
		{
			m_MonsterAction.RemoveFilter();
		}
		
		
		
		
	}

}