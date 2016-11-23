package com.random.iso.items 
{
	
	import com.random.iso.characters.avatar.LayerCharacter;
	import com.random.iso.GameObject;
	import com.random.iso.GameObjectManager;
	import com.random.iso.consts.GameConstants;
	import com.random.iso.items.FacingProp;
	import com.random.iso.consts.AnimationConstants;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import org.flixel.FlxLoadSprite;
	import com.random.iso.utils.AnimationLoader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filters.GlowFilter;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import org.flixel.FlxG;
	/**
	 * in game traps
	 * ...
	 * @author  Allen Halsted
	 */
	public class TrapObject extends GameObject
	{
		
		public static const DONE:String = "done";
		
		private var m_TrapImage:FlxLoadSprite;
		private var m_Notused:Boolean = false;
		private var m_AnimationLoader:AnimationLoader;
		private var m_GlowEffect:GlowFilter = null;
		private var m_Hidden:Boolean = true;
		private var m_XmlData:XML;
		private var m_LoadingXML:Boolean = false;
		private var m_Delay:Number;
		private var m_Fading:Boolean = false;
		private var m_ActivateChance:int = 50;
		protected var m_SE_Default:FacingProp;
		private var m_FileName:String = "";
		public static var RenderLayer:int = 2;
		
		public function TrapObject(editMode:Boolean, game:GameObjectManager) 
		{
			m_Game = game;
			m_EditMode = editMode;
			m_Hidden = !editMode;
			m_Layer = 2;
			m_Rows = 1;
			m_Cols = 1;
			m_TrapImage = new FlxLoadSprite();
			m_Overlap = false;
			if (m_EditMode)
				m_GlowEffect = new GlowFilter(0x00009900);
			if (m_GlowEffect != null)
				m_GlowEffect.inner = true;	
		}
		
		public function loadFromURL(file:String):void
		{
			var xmlLoader:URLLoader = new URLLoader();
			m_LoadingXML = true;
			xmlLoader.addEventListener(Event.COMPLETE, onLoadXML);
			xmlLoader.load(new URLRequest(GameConstants.RESOURCE_BASE+file));
		}
		
		protected function loadAnimationProperties(xml:XMLList, action:String):FacingProp
		{
			var rtnProperties:FacingProp = new FacingProp();
			rtnProperties.FrameCount = int(xml.@frames);
			rtnProperties.Rows = int(xml.@rows);
			rtnProperties.Cols = int(xml.@cols);
			rtnProperties.xOffset = int(xml.@x_offset);
			rtnProperties.yOffset = int(xml.@y_offset);
			rtnProperties.AnimationType = String(xml.@animation).toUpperCase();
			rtnProperties.setFrames(xml);
			rtnProperties.Action = action;
			return rtnProperties;
		}
		
		public function loadFromXML(xml:XML):void
		{
			m_XmlData = xml;
			//basic item properties
			m_ObjectID = int(xml.property.@id);
			m_ThreatRows = int(xml.@threatrows);
			m_ThreatCols = int(xml.@threatcols);
			m_Height = int(xml.@height);
			m_Width = int(xml.@width);
			m_OwnerItemID = xml.@itemid;
			//tell the trap were it needs to be
			var xpos:int = int(xml.@xpos);
			var ypos:int = int(xml.@ypos);
			
			m_ActivateChance = int(xml.@activate);
						
			m_SE_Default = loadAnimationProperties(xml.child("SE_Default"), AnimationConstants.SE_DEFAULT);
			
			//default settings for SE			
			m_xOffset = m_SE_Default.xOffset;
			m_yOffset = m_SE_Default.yOffset;
			
			m_Rows = m_SE_Default.Rows;
			m_Cols = m_SE_Default.Cols
			
			setPosition(xpos, ypos);
			//trap will joing itself to the world
			joinGameWorld();

			
			var url:String  = xml.@file;
			if (url != "")
			{
				m_FileName = url;
				m_AnimationLoader = new AnimationLoader();
				m_AnimationLoader.addEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
				m_AnimationLoader.loadFile(GameConstants.RESOURCE_BASE+url, false);
			}else
			{
				//somthing is wrong so just surpress it and go on
				m_Notused = true;
				m_Loaded = true;
				dispatchEvent(new Event(DONE));
			}
			//this will only happen in edit mode
			getEditorData(xml);	
			
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
		
			if (RenderLayer == 2)
			{
				//add to life list
				m_Game.LayerTwoList.push(this);
				m_Game.sortLifeLayer();
			}else
			{
				m_Game.LayerThreeList.push(this);
			}
			
			//this list will update the animation
			m_Game.SpriteObjectList.push(this);
			//put the item into the map
			m_Game.Map.placeMonster(this);
			
			//add to master list
			m_Game.MasterObjectList.push(this);
		}
		
		public function leaveGameWorld():void
		{
			//remove to life list
			m_Game.removeItem(this,true);
		}
		
		//event when the server has returned and xml
		public function onLoadXML(e:Event):void {
			loadFromXML( new XML(e.target.data) );			
		}	
		
		//set the objects positon in the game world and on the screen
		override public function setPosition(posX:int, posY:int):void {
			super.setPosition(posX, posY);
			m_TrapImage.x = m_ScreenX + m_xOffset;
			m_TrapImage.y = m_ScreenY + m_yOffset;
		}
		
		//free memory allocate to this object
		override public function cleanUp():void 
		{
			m_Loaded = false;
			m_TrapImage.kill();
			m_TrapImage = null;
			
		}
		//get a reference to the trap artwork
		public function get TrapImage():FlxLoadSprite 
		{
			return m_TrapImage;
		}

		
		public function showTrap():void {
			m_Hidden = false;
		}
		//The image has downloaded from the sever
		private function onAnimationDoneLoading(e:Event):void {
			m_TrapImage.loadExtGraphic(m_AnimationLoader.SpriteImage, m_FileName, false, true, false, m_Width, m_Height, true);
			
			//m_TrapImage.alpha = .05;
			m_TrapImage.addAnimation(m_SE_Default.Action, m_SE_Default.Frames, m_SE_Default.FPS, m_SE_Default.Looped);
			m_TrapImage.play(m_SE_Default.Action);
			
			m_Width = m_TrapImage.width;
			m_Height = m_TrapImage.height;
			dispatchEvent(new Event(DONE));
			m_Loaded = true;
			if (m_NewItem)
				m_TrapImage.SetFilter(m_NewItemGlowEffect);
	
			m_AnimationLoader.removeEventListener(AnimationLoader.DONE, onAnimationDoneLoading);	
			m_AnimationLoader = null;
		}
		
		override public function render():void
		{
			//render the image on the screen
			if(m_Loaded && !m_Hidden)
				m_TrapImage.render()	
		}
		
		//update the image animation
		override public function update():void
		{
			if (m_Loaded && !m_Hidden)
				m_TrapImage.update();	
				
			if (m_Fading)
			{
				m_TrapImage.alpha -= FlxG.elapsed/m_Delay;
				if(m_TrapImage.alpha <= 0)
				{
					m_TrapImage.alpha = 0;
					leaveGameWorld();
				}	
			}
		}
		
		//override mouse to not dispatch events
		override public function getMouseOver(x:int, y:int):Boolean
		{
			//image not loaded yet so who cares
			if (!m_TrapImage) return false;
			
			if (!m_MouseOver)
			{//mouse was not here last frame
				if (x > m_TrapImage.x && x < (m_TrapImage.x + m_Width))
				{//moouse is inside the width of the bounding box
					if (y > m_TrapImage.y && y < (m_TrapImage.y + m_Height))
					{//mouse is inside the hight of the bounding box
						if (m_TrapImage.pixels.hitTest(new Point(m_TrapImage.x, m_TrapImage.y), 0, new Point(x, y)))
						{//mouse is over non transparent parts of the image
							m_MouseOver = true;
							onMouseOver();
							return true;
						}
					}
				}
			}else
			{
				if (x > m_TrapImage.x && x < (m_TrapImage.x + m_Width))
				{//mouse still inside the boudning box width
					if (y > m_TrapImage.y && y < (m_TrapImage.y + m_Height))
					{//mouse still inside the bounding box height
						if (m_TrapImage.pixels.hitTest(new Point(m_TrapImage.x, m_TrapImage.y), 0, new Point(x, y)))
						{//mouse still over the image
							return true;
						}
					}
				}
				//the mouse has left the image
				m_MouseOver = false;
				onMouseOut();		
				return false;
			}
			//mouse was never over the image
			return false;
		}
		
		//override mouse to not dispatch events
		override public function setMouseOut():void 
		{
			if (m_EditMode && m_MouseOver)
				onMouseOut();	
			m_MouseOver = false;
		}
		
		override public function onMouseClick(x:int, y:int):void { 
			
		}
		
		//when the mouse leaves remove the glow effect
		override public function onMouseOver():void {
			if (m_EditMode && m_GlowEffect != null && m_NewItem == false)
				m_TrapImage.SetFilter(m_GlowEffect);
		}
		
		//when the mouse enters add the glow effect
		override public function onMouseOut():void {
			if (m_EditMode && m_GlowEffect != null && m_NewItem == false)
				m_TrapImage.RemoveFilter();
			
		}
		
		override public function addGlowEffect(glow:GlowFilter):void
		{
			if (m_NewItem)//dont double up
				m_NewItemGlowEffect = glow;
		}
		
		override public function removeGlowEffect():void
		{
			m_TrapImage.RemoveFilter();
		}
		
		public function attackPlayer(player:LayerCharacter):Boolean {
			
			var win:int = (1 + (100 - 1)) * Math.random();
			var rtn:Boolean = false
			
			if (win < m_ActivateChance)
			{
				rtn = true;
				setPosition(player.xPos, player.yPos);
				showTrap();
				m_Game.Map.removeMonster(this);
				fadeAway();
			}
			return rtn;
		}
		
		
		
		
		private function fadeAway():void
		{
			m_Delay = 2;
			m_TrapImage.alpha = 1;
			m_Fading = true;
		}
		

	}

}