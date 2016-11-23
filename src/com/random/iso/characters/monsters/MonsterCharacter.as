package com.random.iso.characters.monsters 
{
	
	import com.random.iso.characters.ai.*;
	import com.random.iso.GameObject;
	import com.random.iso.GameObjectManager;
	import com.random.iso.characters.monsters.MonsterAction;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import com.random.iso.consts.*;
	import com.random.iso.MobileObject;
	import flash.filters.GlowFilter;
	import com.random.iso.ui.ToolTips;
		
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class MonsterCharacter extends MobileObject
	{
		
		public static const READY:String = "READY";
		 
		private var m_ActionIdle:MonsterAction;
		private var m_ActionWalk:MonsterAction;
		private var m_XmlData:XML;
		private var m_LoadingXML:Boolean;
		private var m_AI:BasicAI;
		private var m_MeanderAI:MeanderAI;
		private var m_DefenseAI:DefenseAI;
		private var m_DeathAI:DeathAI;
		private var m_AttackAI:AttackAI;
		private var m_JoinedWorld:Boolean = false;
		private var m_Alpha:Number = 1;
		private var m_MouseOverMonster:Boolean = false;
		
		public function MonsterCharacter(editmode:Boolean, game:GameObjectManager) 
		{
			super();
			m_Game = game;
			m_EditMode = editmode;
			m_Layer = 2;
			m_Walkable = false;
			m_CurrentAction =  ActionConstants.IDLE;
			m_PreviousAction =  ActionConstants.IDLE;
			m_Overlap = false;
			m_FacingCount = 4;
			m_MeanderAI = new MeanderAI(this, game);
			m_DefenseAI = new DefenseAI(this, game);
			m_DeathAI = new DeathAI(this, game);
			m_AttackAI = new AttackAI(this, game);
			m_AI = m_MeanderAI;
			m_Type = ObjTypes.MOB;
		}
		
		public function get Alpha():Number { return m_Alpha; }
		public function set Alpha(value:Number):void {
			m_Alpha = value;
			m_ActionIdle.setAlpha(value);
			m_ActionWalk.setAlpha(value);
		}

		
		
		public function loadFromURL(file:String):void
		{
			var xmlLoader:URLLoader = new URLLoader();
			
			xmlLoader.addEventListener(Event.COMPLETE, onLoadXML);
			xmlLoader.load(new URLRequest(GameConstants.RESOURCE_BASE+file));
		}
		
		public function loadFromXML(xml:XML):void
		{
			m_LoadingXML = true;
			m_XmlData = xml;
			m_Rows = 1;
			m_Cols = 1;
			m_ThreatRows = int(xml.@threatrows);
			m_ThreatCols = int(xml.@threatcols);
			//default settings for SE			
			m_CurrentDirection = xml.@direction;
			m_xOffset =  int(xml.@x_offset);
			m_yOffset = int(xml.@y_offset);
			m_OwnerItemID = xml.@itemid;
			m_ObjectID = int(xml.property.@id);

			var xpos:int = int(xml.@xpos);
			var ypos:int = int(xml.@ypos);
			setPosition(xpos, ypos);
			
			m_ActionIdle = new MonsterAction();
			m_ActionWalk = new MonsterAction();
			m_ActionIdle.EditMode = m_EditMode;
			m_ActionWalk.EditMode = m_EditMode;
			
			joinGameWorld();
			m_ActionIdle.addEventListener(MonsterAction.READY, onIdleReady);
			m_ActionIdle.LoadActionAnimations(m_XmlData, ActionConstants.IDLE, IsoConstants.DIR_SW);
			
			m_ActionWalk.addEventListener(MonsterAction.READY, onWalkReady);
			m_ActionWalk.LoadActionAnimations(m_XmlData, ActionConstants.WALK, IsoConstants.DIR_SW);
			getEditorData(xml);
			m_Loaded = true;
			
			if (!m_EditMode)
			{
				if(m_Game.GameMode == 0)
					ToolTip = "This is your monster. It will defend your realm from pesky adventurers.";	
				else
					ToolTip = xml.property.@itemname + ": Left click to attack this monster.";	
				
				
			}
		}

		override public function toXML():String 
		{
			m_XmlData.@direction = m_CurrentDirection;
			m_XmlData.@xpos = String(m_PosX);
			m_XmlData.@ypos = String(m_PosY);
			
			return m_XmlData.toString();
			
		}
		
		public function joinGameWorld():void
		{
			//add to life list
			m_Game.LayerTwoList.push(this);
			m_Game.Map.placeMonster(this);
			m_Game.sortLifeLayer();
			//add to mob list
			m_Game.MobileObjectList.push(this);
			//add to master list
			m_Game.MasterObjectList.push(this);
			m_JoinedWorld = true;
		}
		//fire on mouse click
		override public function onMouseClick(x:int, y:int):void 
		{ 
			if (m_CurrentStatus == StatusConstants.DEAD)
				return;

			//Stop AI
			//face player
			changeAI(AIConstants.DEFEND);
			//wait for combat
		}
		
		override public function cleanUp():void 
		{
			m_CurrentAction = "none";
			m_ActionIdle.cleanUp();
			m_ActionWalk.cleanUp();
		}
		override public function setDir(dir:String):void
		{
			super.setDir(dir);
			
			m_CurrentDirection = dir;
			m_ActionIdle.play(dir);
			m_ActionWalk.play(dir);
		}
		
		
		public function onLoadXML(e:Event):void {
			loadFromXML( new XML(e.target.data) );	
		}	
		
		
		private function onIdleReady(e:Event):void {
			m_ActionIdle.removeEventListener(MonsterAction.READY, onIdleReady);
			setDir(m_CurrentDirection);
			if (m_NewItem)
			{
				if(m_NewItemGlowEffect)
					m_ActionIdle.addGlowEffect(m_NewItemGlowEffect);
			}
			
		}

		private function onWalkReady(e:Event):void {
			m_ActionWalk.removeEventListener(MonsterAction.READY, onWalkReady);
			dispatchEvent(new Event(READY));
			m_LoadingXML = false;
			m_AI.start();
		}
		
		override public function isLoaded():Boolean {
			
			if (!m_LoadingXML)
				return m_ActionIdle.loaded() && m_ActionWalk.loaded();
			else
				return false;
		}
		
		override public function update():void  {
			
			super.update();
			
			if (!m_EditMode)
				m_AI.update();
			switch (m_CurrentAction)
			{
				case ActionConstants.IDLE:
					m_ActionIdle.screenPoint( m_ScreenX + m_xOffset, m_ScreenY + m_yOffset);
					m_ActionIdle.update();
					break;
				case ActionConstants.WALK:
					m_ActionWalk.screenPoint( m_ScreenX + m_xOffset, m_ScreenY + m_yOffset);
					m_ActionWalk.update();
					break;
			}
					
		}
		override public function render():void  {
			
			if (!m_JoinedWorld) return;
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
		
		//override mouse to not dispatch events
		override public function getMouseOver(x:int, y:int):Boolean {
			var rtn:Boolean = false;
			
			if (m_CurrentStatus == StatusConstants.DEAD)
				return rtn;
			
			rtn = m_ActionIdle.getMouseOver(x, y);
			if (rtn)
			{
				if (!m_MouseOverMonster)
				{
					if (m_ToolTipBubble == null && (m_ToolTip != null))
					{
						ToolTips.hide();
						m_ToolTipBubble = new ToolTips(this);
						m_ToolTipBubble.text = m_ToolTip;
						m_ToolTipBubble.init()
						m_ToolTipBubble.addToStage();
					}
					else
					{
						ToolTips.hide();
						if (m_ToolTip != null)
							m_ToolTipBubble.addToStage();
					}	
					m_MouseOverMonster = true;
				}else 
				{
				  updateToolTip();
				}
			}else
				m_MouseOverMonster = false;
				
			return rtn;
		}
		
		//override mouse to not dispatch events
		override public function setMouseOut():void {
			m_ActionIdle.setMouseOut();
			//ToolTips.hide();
			m_MouseOverMonster = false;
			if (m_ToolTipBubble)
			{
				if (m_ToolTipBubble.parent)
				{
					m_ToolTipBubble.parent.removeChild(m_ToolTipBubble);
					m_ToolTipBubble = null;
				}
			}
				
		}
		
		override public function onStopMoving():void { 
			super.onStopMoving();
			m_WayPoints = [];
			doAction(ActionConstants.IDLE);
			if (m_AI) m_AI.onStopMoving(); 
		}
		
		public function changeAI(ai:String):void {
			
			m_AI.stop();
			
			switch (ai)
			{
				case AIConstants.DEFEND:
					m_AI = m_DefenseAI;
					m_AI.start();
					break;
				case AIConstants.ATTACK:
					m_AI = m_AttackAI;
					m_AI.start();
					break;
				case AIConstants.MEANDER:
					m_AI = m_MeanderAI;
					m_AI.start();
					break;
				case AIConstants.DEATH:
					m_AI = m_DeathAI;
					m_AI.start();
					break;
			}
			
		}
		
		public function die():void {
			m_CurrentStatus = StatusConstants.DEAD;
			doAction(ActionConstants.IDLE);
			changeAI(AIConstants.DEATH);
		}
		public function attack(target:GameObject):void {
			
			faceTarget(target.xPos, target.yPos);
			doAction(ActionConstants.ATTACK);
		}
		
		override public function addGlowEffect(glow:GlowFilter):void
		{
			if (m_NewItem)//dont double up
				m_NewItemGlowEffect = glow;
		}
		
		override public function removeGlowEffect():void
		{
			m_ActionIdle.removeGlowEffect();
			m_ActionWalk.removeGlowEffect();
		}
		
		
	}

}