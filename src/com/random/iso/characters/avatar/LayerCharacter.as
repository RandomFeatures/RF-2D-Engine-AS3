package com.random.iso.characters.avatar
{
	import com.random.iso.GameObjectManager;
	import com.random.iso.consts.*;
	import com.random.iso.MobileObject
	import com.random.iso.GameObject
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import com.random.iso.utils.IsoPoint;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class LayerCharacter extends MobileObject
	{
		
		public static const READY:String = "READY";
		 
		private var m_ActionIdle:CharacterAction;
		private var m_ActionWalk:CharacterAction;
		private var m_ImageType:int = 0;
		private var m_XmlData:XML;
		private var m_LoadingXML:Boolean;
		private var m_IdleReady:Boolean;
		private var m_WalkReady:Boolean;
		private var m_AlreadyLoaded:Boolean = false;	
		
		public function get xmlData():XML { return m_XmlData; }
		public function LayerCharacter():void
		{
			m_CurrentAction =  ActionConstants.IDLE;
			m_PreviousAction =  ActionConstants.IDLE;
			
			m_ActionIdle = new CharacterAction();
			m_ActionWalk = new CharacterAction();
			m_Type = ObjTypes.CHAR;
		}
		
		override public function setDir(dir:String):void
		{
			super.setDir(dir);
			
			m_CurrentDirection = dir;
			if (m_ActionIdle) m_ActionIdle.play(dir);
			if (m_ActionWalk) m_ActionWalk.play(dir);
		}
		
		public function loadfromURL(url:String):void
		{
			var xmlLoader:URLLoader = new URLLoader();
			
			m_XmlData = new XML();
			
			m_LoadingXML = true;
			xmlLoader.addEventListener(Event.COMPLETE, onLoadXML);
			xmlLoader.load(new URLRequest(url));
		}
		
		public function onLoadXML(e:Event):void {
			loadFromXML(new XML(e.target.data));
		}	
		
		public function loadFromXML(xml:XML):void {
			
			m_XmlData = xml;
			if (m_XmlData.dataset.Avatar.property.type == "layered") m_ImageType = 0;

			m_ActionIdle.addEventListener(CharacterAction.READY, onIdleReady);
			if (!m_AlreadyLoaded)
				m_ActionIdle.LoadLayers(m_XmlData, ActionConstants.IDLE, IsoConstants.DIR_SW);
			else
				m_ActionIdle.reloadLayers(m_XmlData, ActionConstants.IDLE, IsoConstants.DIR_SW);
			
			m_ActionWalk.addEventListener(CharacterAction.READY, onWalkReady);
			//m_ActionIdle.play(m_CurrentDirection);
			if (!m_AlreadyLoaded)
				m_ActionWalk.LoadLayers(m_XmlData, ActionConstants.WALK, IsoConstants.DIR_SW);
			else
				m_ActionWalk.reloadLayers(m_XmlData, ActionConstants.WALK, IsoConstants.DIR_SW);
				
			m_AlreadyLoaded = true;	
			dispatchEvent(new Event(READY));	
		}
		
		override public function toXML():String 
		{
			m_XmlData.@direction = m_CurrentDirection;
			m_XmlData.@xpos = String(m_PosX);
			m_XmlData.@ypos = String(m_PosY);

			return m_XmlData.toString();
		}
		
		private function onIdleReady(e:Event):void {
			m_ActionIdle.removeEventListener(CharacterAction.READY, onIdleReady);
			m_IdleReady = true;
		}

		private function onWalkReady(e:Event):void {
			m_ActionWalk.removeEventListener(CharacterAction.READY, onWalkReady);
			m_LoadingXML = false;
			m_WalkReady = true;
		}

		override public function isLoaded():Boolean {
			
			if (m_IdleReady && m_WalkReady)
				return true;
			else
				return false;
		}
		
		override public function update():void  {
			
			super.update();
			switch (m_CurrentAction)
			{
				case ActionConstants.IDLE:
					m_ActionIdle.screenPoint(m_ScreenX, m_ScreenY);
					m_ActionIdle.update();
					break;
				case ActionConstants.WALK:
					m_ActionWalk.screenPoint(m_ScreenX, m_ScreenY);
					m_ActionWalk.update();
					break;
			}
					
		}
		override public function render():void  {
			
			if (!m_Visible) return;
			super.render();
			
			switch (m_CurrentAction)
			{
				case ActionConstants.IDLE:
					m_ActionIdle.render();
					break;
				case ActionConstants.WALK:
					m_ActionWalk.render();
					break;
			}
		}
		
		override public function walk(wayPoints:Array):void 
		{
			super.walk(wayPoints);
			doAction(ActionConstants.WALK)
		}
		
		override public function onStopMoving():void { 
			super.onStopMoving();
			m_WayPoints = [];
			doAction(ActionConstants.IDLE);
		
		}
		
		public function wakeUp():void {
			m_ActionIdle.wakeUp();
		}
	}

}