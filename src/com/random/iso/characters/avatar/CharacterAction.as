package com.random.iso.characters.avatar
{
	import org.flixel.*
	import com.random.iso.consts.ActionConstants;
	import com.random.iso.characters.animation.AniSprite;
	import flash.events.Event;
	import com.random.iso.consts.IsoConstants;
	import com.random.iso.consts.GameConstants;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class CharacterAction extends EventDispatcher
	{
		public static const READY:String = "ready";
		
		private var m_Base:AniSprite = null;
		private var m_Hair:AniSprite = null;
		private var m_Head:AniSprite = null;
		private var m_Body:AniSprite = null;
		private var m_MainHand:AniSprite = null;
		private var m_OffHand:AniSprite = null;
		private var m_Accessory:AniSprite = null;

		protected var m_FrameWidth:int;
		protected var m_FrameHeight:int;
		protected var m_ImageWidth:int;
		protected var m_ImageHeight:int;
		protected var m_BlendMode:int;
		protected var m_Mode:int;
		protected var m_Loaded:Boolean;
		protected var m_Dir: String;
		protected var m_Action: String;
		protected var m_LoadingLayer:Boolean = true;
		protected var m_HotX:int;
		protected var m_HotY:int;
		protected var m_FPS:Number = 10;	
		protected var m_AnimationType:String = "NONE"
		
		protected var m_LayersLoaded:int = 0;
		protected var m_FrameCount:int = 8;
		protected var m_LayersToLoad:int = 7;
		
		public function LoadLayers(chrXML:XML, action:String, dir:String):void
		{
			//trace(chrXML);
			m_Dir = dir;
			m_Action = action;
			
			//use base framecout, fps and animation for all
			m_FrameCount = chrXML.dataset.Avatar.equipment.base.action.(@name == action).@frames;
			if (m_FrameCount == 4) 
				m_FPS = (0.3 + (1.0 - 0.3)) * Math.random();
			else
				m_FPS = chrXML.dataset.Avatar.equipment.base.action.(@name == action).@fps;
			
			m_AnimationType = String(chrXML.dataset.Avatar.equipment.base.action.(@name == action).@animation).toUpperCase();
			
			var urlBase:String = chrXML.dataset.Avatar.equipment.base.action.(@name == action).@image;
			var colorBase:uint = chrXML.dataset.Avatar.equipment.base.@color;
			
			var urlHead:String = chrXML.dataset.Avatar.equipment.head.action.(@name == action).@image;
			var colorHead:uint = chrXML.dataset.Avatar.equipment.head.@color;
			
			var urlHair:String;
			var colorHair:uint = chrXML.dataset.Avatar.equipment.hair.@color;
			if (urlHead == "")//no hat so get hair
				urlHair = chrXML.dataset.Avatar.equipment.hair.action.(@name == action).@image;
			else//hat so get hathair
				urlHair = chrXML.dataset.Avatar.equipment.hathair.action.(@name == action).@image;
			
			
			
			var urlBody:String = chrXML.dataset.Avatar.equipment.body.action.(@name == action).@image;
			var colorBody:uint = chrXML.dataset.Avatar.equipment.body.@color;
			var urlMainHand:String = chrXML.dataset.Avatar.equipment.mainhand.action.(@name == action).@image;
			var colorMainHand:uint = chrXML.dataset.Avatar.equipment.mainhand.@color;
			var urlOffHand:String = chrXML.dataset.Avatar.equipment.offhand.action.(@name == action).@image;
			var colorOffHand:uint = chrXML.dataset.Avatar.equipment.offhand.@color;
			var urlCloak:String = chrXML.dataset.Avatar.equipment.cloak.action.(@name == action).@image;
			var colorCloak:uint = chrXML.dataset.Avatar.equipment.cloak.@color;
			
					
			m_HotX = int(chrXML.dataset.Avatar.property.@hotx);
			m_HotY = int(chrXML.dataset.Avatar.property.@hoty)-GameConstants.TILEHALFHEIGHT;
			m_FrameWidth = int(chrXML.dataset.Avatar.property.@width);
			m_FrameHeight = int(chrXML.dataset.Avatar.property.@height);
			
			m_Base = new AniSprite(0, 0);
			//m_Base.addEventListener(AniSprite.DONE, onBaseLoaded);
			m_Base.loadLayerAnimation(urlBase, true, m_FrameWidth, m_FrameHeight);
			m_Base.color = colorBase;
			assignAnimations(m_Base);
			m_Base.update();
			
			m_Hair = new AniSprite(0,0);
			//m_Hair.addEventListener(AniSprite.DONE, onHairLoaded);
			m_Hair.loadLayerAnimation(urlHair, true, m_FrameWidth, m_FrameHeight);
			m_Hair.color = colorHair;
			assignAnimations(m_Hair);
			m_Hair.update();
			
			m_Head = new AniSprite(0,0);
			//m_Head.addEventListener(AniSprite.DONE, onHeadLoaded);
			m_Head.loadLayerAnimation(urlHead, true, m_FrameWidth, m_FrameHeight);
			m_Head.color = colorHead;
			assignAnimations(m_Head);
			m_Head.update();
			
			m_Body = new AniSprite(0,0);
			//m_Body.addEventListener(AniSprite.DONE, onBodyLoaded);
			m_Body.loadLayerAnimation(urlBody, true, m_FrameWidth, m_FrameHeight);
			m_Body.color = colorBody;
			assignAnimations(m_Body);
			m_Body.update(); 
			
			m_MainHand = new AniSprite(0,0);
			//m_MainHand.addEventListener(AniSprite.DONE, onMainLoaded);
			m_MainHand.loadLayerAnimation(urlMainHand, true, m_FrameWidth, m_FrameHeight);
			m_MainHand.color = colorMainHand;
			assignAnimations(m_MainHand);
			m_MainHand.update();
			
			m_OffHand = new AniSprite(0, 0)
			//m_OffHand.addEventListener(AniSprite.DONE, onOffLoaded);
			m_OffHand.loadLayerAnimation(urlOffHand, true, m_FrameWidth, m_FrameHeight);
			m_OffHand.color = colorOffHand;
			assignAnimations(m_OffHand);
			m_OffHand.update();
			
			m_Accessory = new AniSprite(0,0);
			//m_Accessory.addEventListener(AniSprite.DONE, onCloakLoaded);
			m_Accessory.loadLayerAnimation(urlCloak, true, m_FrameWidth, m_FrameHeight);
			m_Accessory.color = colorCloak;
			assignAnimations(m_Accessory);
			m_Accessory.update();
			
			m_LoadingLayer = false;
			dispatchEvent(new Event(READY));
		}
	
		public function reloadLayers(chrXML:XML, action:String, dir:String):void
		{
			m_LayersLoaded = 0;
			m_LayersToLoad = 0;
			var urlBase:String = chrXML.dataset.Avatar.equipment.base.action.(@name == action).@image;
			var colorBase:uint = chrXML.dataset.Avatar.equipment.base.@color;
			
			var urlHead:String = chrXML.dataset.Avatar.equipment.head.action.(@name == action).@image;
			var colorHead:uint = chrXML.dataset.Avatar.equipment.head.@color;
			
			
			var urlHair:String;
			var colorHair:uint = chrXML.dataset.Avatar.equipment.hair.@color;
			if (urlHead == "")//no hat so get hair
				urlHair = chrXML.dataset.Avatar.equipment.hair.action.(@name == action).@image;
			else//hat so get hathair
				urlHair = chrXML.dataset.Avatar.equipment.hathair.action.(@name == action).@image;
			
			
			var urlBody:String = chrXML.dataset.Avatar.equipment.body.action.(@name == action).@image;
			var colorBody:uint = chrXML.dataset.Avatar.equipment.body.@color;
			var urlMainHand:String = chrXML.dataset.Avatar.equipment.mainhand.action.(@name == action).@image;
			var colorMainHand:uint = chrXML.dataset.Avatar.equipment.mainhand.@color;
			var urlOffHand:String = chrXML.dataset.Avatar.equipment.offhand.action.(@name == action).@image;
			var colorOffHand:uint = chrXML.dataset.Avatar.equipment.offhand.@color;
			var urlCloak:String = chrXML.dataset.Avatar.equipment.cloak.action.(@name == action).@image;
			var colorCloak:uint = chrXML.dataset.Avatar.equipment.cloak.@color;
			
			
			if (!m_Base.checkLoaded(urlBase))
			{
				//m_Base.addEventListener(AniSprite.DONE, onBaseLoaded);
				m_Base.loadLayerAnimation(urlBase, true, m_FrameWidth, m_FrameHeight);
				
				assignAnimations(m_Base);
				m_LayersToLoad += 1;
			}
			m_Base.color = colorBase;
			m_Base.update();
			
			if (!m_Hair.checkLoaded(urlHair))
			{
				//m_Hair.addEventListener(AniSprite.DONE, onBaseLoaded);
				m_Hair.loadLayerAnimation(urlHair, true, m_FrameWidth, m_FrameHeight);
				m_Hair.color = colorHair;
				assignAnimations(m_Hair);
				m_LayersToLoad += 1;
			}
			
			if (!m_Head.checkLoaded(urlHead))
			{
				//m_Head.addEventListener(AniSprite.DONE, onBaseLoaded);
				m_Head.loadLayerAnimation(urlHead, true, m_FrameWidth, m_FrameHeight);
				m_Head.color = colorHead;
				assignAnimations(m_Head);
				m_LayersToLoad += 1;
			}
			
			if (!m_Body.checkLoaded(urlBody))
			{	
				//m_Body.addEventListener(AniSprite.DONE, onBaseLoaded);
				m_Body.loadLayerAnimation(urlBody, true, m_FrameWidth, m_FrameHeight);
				m_Body.color = colorBody;
				assignAnimations(m_Body);
				m_LayersToLoad += 1;
			}
			
			if (!m_MainHand.checkLoaded(urlMainHand))
			{	
				//m_MainHand.addEventListener(AniSprite.DONE, onBaseLoaded);
				m_MainHand.loadLayerAnimation(urlMainHand, true, m_FrameWidth, m_FrameHeight);
				m_MainHand.color = colorMainHand;
				assignAnimations(m_MainHand);
				m_LayersToLoad += 1;
			}
			
			if (!m_OffHand.checkLoaded(urlOffHand))
			{
				//m_OffHand.addEventListener(AniSprite.DONE, onBaseLoaded);
				m_OffHand.loadLayerAnimation(urlOffHand, true, m_FrameWidth, m_FrameHeight);
				m_OffHand.color = colorOffHand;
				assignAnimations(m_OffHand);
				m_LayersToLoad += 1;
			}
			
			if (!m_Accessory.checkLoaded(urlCloak))
			{	
				//m_Accessory.addEventListener(AniSprite.DONE, onBaseLoaded);
				m_Accessory.loadLayerAnimation(urlCloak, true, m_FrameWidth, m_FrameHeight);
				m_Accessory.color = colorCloak;
				assignAnimations(m_Accessory);
				m_LayersToLoad += 1;
			}
			play(m_Dir);
			m_LoadingLayer = false;
			dispatchEvent(new Event(READY));
		}
		
		private function assignAnimations(ani:AniSprite):void
		{
			switch (m_FrameCount)
			{
				case 4:
						ani.fourFrameAnimations(m_FPS, true);
					break;
				case 8:
						ani.eightFrameAnimations(m_FPS, true);
					break;
			}
		}
		
		private function playIdelAnimation():void {
			
			var iframe:int;
			var irow:int;
			switch (m_Dir)
			{
				case IsoConstants.DIR_SE:
					irow = 0;
					break;
				case IsoConstants.DIR_SW:	
					irow = 1;
					break;
				case IsoConstants.DIR_NW:	
					irow = 2;
					break;
				case IsoConstants.DIR_NE:	
					irow = 3;
					break;
			}

			if (m_Base.LayerUsed) iframe = m_Base.randomRowFrame(irow,4);
			if (m_Hair.LayerUsed) m_Hair.frame = iframe;
			if (m_Head.LayerUsed) m_Head.frame = iframe;
			if (m_Body.LayerUsed) m_Body.frame = iframe;
			if (m_MainHand.LayerUsed) m_MainHand.frame = iframe;
			if (m_OffHand.LayerUsed) m_OffHand.frame = iframe;
			if (m_Accessory.LayerUsed) m_Accessory.frame = iframe;
				
			var wait:int = (500 + (10000 - 500)) * Math.random()
			setTimeout(playIdelAnimation, wait);

		}
		
		private function onBaseLoaded(e:Event):void
		{
			m_LayersLoaded = m_LayersLoaded+1;
			m_Base.removeEventListener(AniSprite.DONE, onBaseLoaded);
			assignAnimations(m_Base);
		}

		private function onHairLoaded(e:Event):void
		{
			m_LayersLoaded = m_LayersLoaded+1;
			m_Hair.removeEventListener(AniSprite.DONE, onHairLoaded);
			assignAnimations(m_Hair);
		}

		private function onHeadLoaded(e:Event):void
		{
			m_LayersLoaded = m_LayersLoaded+1;
			m_Head.removeEventListener(AniSprite.DONE, onHeadLoaded);
			assignAnimations(m_Head);
		}
		
		
		private function onBodyLoaded(e:Event):void
		{
			
			m_LayersLoaded = m_LayersLoaded+1;
			m_Body.removeEventListener(AniSprite.DONE, onBodyLoaded);
			assignAnimations(m_Body);
			if (m_LayersLoaded == m_LayersToLoad)
				dispatchEvent(new Event(READY));
		}
		
		private function onMainLoaded(e:Event):void
		{
			m_LayersLoaded = m_LayersLoaded+1;
			m_MainHand.removeEventListener(AniSprite.DONE, onMainLoaded);
			assignAnimations(m_MainHand);
		}
		
		private function onOffLoaded(e:Event):void
		{
			m_LayersLoaded = m_LayersLoaded+1;
			m_OffHand.removeEventListener(AniSprite.DONE, onOffLoaded);
			assignAnimations(m_OffHand);
		}
		
		private function onCloakLoaded(e:Event):void
		{
			m_LayersLoaded = m_LayersLoaded+1;
			m_Accessory.removeEventListener(AniSprite.DONE, onCloakLoaded);
			assignAnimations(m_Accessory);
		}
		
		public function loaded():Boolean {
			var rtn:Boolean;
			
			if (!m_LoadingLayer)
			{
				rtn = m_Base.DoneLoading && m_Hair.DoneLoading && m_Head.DoneLoading && m_Body.DoneLoading && m_MainHand.DoneLoading &&  m_OffHand.DoneLoading && m_Accessory.DoneLoading;
			}	
			else
				rtn = false;
			return rtn;
		}
		
		public function play(dir:String=""):void
		{ 
			if (dir != "")
			{
				m_Dir = dir;
			}
			
			if (m_Base.LayerUsed) m_Base.play(m_Dir);
			if (m_Hair.LayerUsed) m_Hair.play(m_Dir);
			if (m_Head.LayerUsed) m_Head.play(m_Dir);
			if (m_Body.LayerUsed) m_Body.play(m_Dir);
			if (m_MainHand.LayerUsed) m_MainHand.play(m_Dir);
			if (m_OffHand.LayerUsed) m_OffHand.play(m_Dir);
			if (m_Accessory.LayerUsed) m_Accessory.play(m_Dir);
			
			
		};
		/*
		public function Stop() { };
		public function IsPlaying(): Boolean;
		public function SetSpeed(fps:int);
		public function SetFrame(n:int);
		public function SetBlendMode(blend:int);
		public function GetFrame():int;
		public function SetDirection(dir:String);
		*/
		
		public function screenPoint(X:int, Y:int):void
		{
			m_Base.x = X-m_HotX;
			m_Base.y = Y-m_HotY;	
			
			m_Hair.x = X-m_HotX;
			m_Hair.y = Y-m_HotY;	

			m_Head.x = X-m_HotX;
			m_Head.y = Y-m_HotY;	

			m_Body.x = X-m_HotX;
			m_Body.y = Y-m_HotY;	

			m_MainHand.x = X-m_HotX;
			m_MainHand.y = Y-m_HotY;	

			m_OffHand.x = X-m_HotX;
			m_OffHand.y = Y-m_HotY;	

			m_Accessory.x = X-m_HotX;
			m_Accessory.y = Y - m_HotY;	
		}
		
		public function render():void
		{
			if (m_Base.LayerUsed) m_Base.render();
			if (m_Hair.LayerUsed) m_Hair.render();
			if (m_Head.LayerUsed) m_Head.render();
			if (m_Body.LayerUsed) m_Body.render();
			if (m_MainHand.LayerUsed) m_MainHand.render();
			if (m_OffHand.LayerUsed) m_OffHand.render();
			if (m_Accessory.LayerUsed) m_Accessory.render();
		}
		
		public function update():void {
			
			if (m_Base.LayerUsed) m_Base.update();
			if (m_Hair.LayerUsed) m_Hair.update();
			if (m_Head.LayerUsed) m_Head.update();
			if (m_Body.LayerUsed) m_Body.update();
			if (m_MainHand.LayerUsed) m_MainHand.update();
			if (m_OffHand.LayerUsed) m_OffHand.update();
			if (m_Accessory.LayerUsed) m_Accessory.update();
		}

		public function get Dir():String { return m_Dir; }
		public function set Dir(value:String):void {
			m_Dir = value;
		}
		
		public function wakeUp():void {
			if (m_Base.LayerUsed) m_Base.forceUpdate();
			if (m_Hair.LayerUsed) m_Hair.forceUpdate();
			if (m_Head.LayerUsed) m_Head.forceUpdate();
			if (m_Body.LayerUsed) m_Body.forceUpdate();
			if (m_MainHand.LayerUsed) m_MainHand.forceUpdate();
			if (m_OffHand.LayerUsed) m_OffHand.forceUpdate();
			if (m_Accessory.LayerUsed) m_Accessory.forceUpdate();
		}
		
	}

}