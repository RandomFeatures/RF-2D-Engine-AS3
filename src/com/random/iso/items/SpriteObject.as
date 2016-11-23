package com.random.iso.items 
{
	import com.random.iso.GameObject;
	import com.random.iso.GameObjectManager;
	import com.random.iso.consts.GameConstants;
	import com.random.iso.consts.IsoConstants;
	import com.random.iso.consts.AnimationConstants;
	import com.random.iso.items.FacingProp;
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
	import com.random.iso.ui.ToolTips;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class SpriteObject extends GameObject
	{
		
		public static const DONE:String = "done";
		
		protected var m_SpriteImage:FlxLoadSprite;
		protected var m_Notused:Boolean = false;
		protected var m_AnimationLoader:AnimationLoader;
		protected var m_GlowEffect:GlowFilter = null;
		protected var m_XmlData:XML;
		protected var m_LoadingXML:Boolean = false;;

		protected var m_SE_Default:FacingProp;
		protected var m_SW_Default:FacingProp;
		protected var m_NE_Default:FacingProp;
		protected var m_NW_Default:FacingProp;
		protected var m_FileName:String;
		
		public function SpriteObject(editMode:Boolean, game:GameObjectManager) 
		{
			m_Game = game;
			m_EditMode = editMode;
			m_SpriteImage = new FlxLoadSprite();
			if (m_EditMode && m_GlowEffect == null)
			{
				m_GlowEffect = new GlowFilter(0x00009900);
				m_GlowEffect.inner = true;
			}
		}
	
		
	//go get the xml from the webserver
		public function loadFromURL(file:String):void
		{
			var xmlLoader:URLLoader = new URLLoader();
			m_LoadingXML = true;
			xmlLoader.addEventListener(Event.COMPLETE, onLoadXML);
			xmlLoader.load(new URLRequest(GameConstants.RESOURCE_BASE+file));
		}
		
		protected function loadFacingProperties(xml:XMLList, action:String):FacingProp
		{
			
			var rtnProperties:FacingProp = new FacingProp();
			rtnProperties.FrameCount = int(xml.@frames);
			rtnProperties.Rows = int(xml.@rows);
			rtnProperties.Cols = int(xml.@cols);
			rtnProperties.xOffset = int(xml.@x_offset);
			rtnProperties.yOffset = int(xml.@y_offset);
			rtnProperties.FPS = Number(xml.@fps);
			rtnProperties.AnimationType = String(xml.@animation).toUpperCase();
			rtnProperties.setFrames(xml);
			rtnProperties.Action = action;
			return rtnProperties;
		}
		
		//load the static from the xml data
		virtual public function loadFromXML(xml:XML):void
		{
			
			m_XmlData = xml;
			
			m_ObjectID = int(xml.property.@id);
			m_Layer = int(xml.@layer);
			m_FacingCount = int(xml.@facings);
			m_Height = int(xml.@height);
			m_Width = int(xml.@width);
			m_OwnerItemID = xml.@itemid;
			//Yes switch case statements require breaks or they just keep going
            //It is intended to cascade as it goes so just leave it alone.
            //putting in the breaks WILL literally break this code.
            //normally I try to code by the book but this was just too much fun.
            //if it doesn't seem fun to you then perhaps you should reconsider your career
			switch (m_FacingCount)
			{
					
				case 4:
					m_NE_Default = loadFacingProperties(xml.child("NE_Default"), AnimationConstants.NE_DEFAULT);
					m_NW_Default = loadFacingProperties(xml.child("NW_Default"), AnimationConstants.NW_DEFAULT);
				case 2:
					m_SW_Default = loadFacingProperties(xml.child("SW_Default"), AnimationConstants.SW_DEFAULT);
				case 1:
					m_SE_Default = loadFacingProperties(xml.child("SE_Default"), AnimationConstants.SE_DEFAULT);
			}
			
			//default settings for SE			
			m_xOffset = m_SE_Default.xOffset;
			m_yOffset = m_SE_Default.yOffset;
			m_Rows = m_SE_Default.Rows;
			m_Cols = m_SE_Default.Cols
			
			m_CurrentDirection = xml.@direction;
			
			if (xml.@walkable == "true")
				m_Walkable = true
			else
				m_Walkable = false;
				
			if (xml.@overlap == "true")
				m_Overlap = true
			else
				m_Overlap = false; 
				
			//set the objcest position 
			var xpos:int = int(xml.@xpos);
			var ypos:int = int(xml.@ypos);
			setPosition(xpos, ypos);
			//add itself to the game world
			joinGameWorld();
			
			//load the art file
			var url:String  = xml.@file;
			if (url != "")
			{
				m_FileName = url;
				m_AnimationLoader = new AnimationLoader();
				m_AnimationLoader.addEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
				m_AnimationLoader.loadFile(GameConstants.RESOURCE_BASE+url, false);
			}else
			{
				//no art file so just ignore it
				m_Notused = true;
				m_Loaded = true;
				dispatchEvent(new Event(DONE));
			}
			//if in edit mode then load the editor data
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
			//m_Game.Map.placeItem(this);
			switch (m_Layer)
			{
				case 0: //put both 0 and 1 in LayerOneList
				case 1:
					m_Game.LayerOneList.push(this);
					break;
				case 2:
					//add to life list
					m_Game.LayerTwoList.push(this);
					m_Game.sortLifeLayer();
					break;
				case 3:
					m_Game.LayerThreeList.push(this);
					break;
			}
			
			//add to sprite list so animation is updated
			m_Game.SpriteObjectList.push(this);
			
			//add to master list
			m_Game.MasterObjectList.push(this);
		}
		
		//event for getting xml from the server
		public function onLoadXML(e:Event):void {
			loadFromXML( new XML(e.target.data) );			
		}	
		
		//set the object positon in the world and on the screen
		override public function setPosition(posX:int, posY:int):void {
			super.setPosition(posX, posY);
			m_SpriteImage.x = m_ScreenX+ m_xOffset;
			m_SpriteImage.y = m_ScreenY + m_yOffset;
		}
		
		//get the refernece to the art image
		public function get SpriteImage():FlxLoadSprite 
		{
			return m_SpriteImage;
		}
		
		//free up memory allocated for this object
		override public function cleanUp():void 
		{
			m_Loaded = false;
			m_SpriteImage.kill();
			m_SpriteImage = null;
		}
		
		//The image has downloaded from the sever
		private function onAnimationDoneLoading(e:Event):void {
			
			m_SpriteImage.loadExtGraphic(m_AnimationLoader.SpriteImage, m_FileName, false, true, false, m_Width, m_Height, true);
			
			m_Width = m_SpriteImage.width;
			m_Height = m_SpriteImage.height;
			switch (m_FacingCount)
			{
				case 1:
					m_SpriteImage.addAnimation(m_SE_Default.Action, m_SE_Default.Frames, m_SE_Default.FPS, m_SE_Default.Looped);
					break;
				case 2:
					m_SpriteImage.addAnimation(m_SE_Default.Action, m_SE_Default.Frames, m_SE_Default.FPS, m_SE_Default.Looped);
					m_SpriteImage.addAnimation(m_SW_Default.Action, m_SW_Default.Frames, m_SW_Default.FPS, m_SW_Default.Looped);
					
					break;
				case 4:
					m_SpriteImage.addAnimation(m_SE_Default.Action, m_SE_Default.Frames, m_SE_Default.FPS, m_SE_Default.Looped);
					m_SpriteImage.addAnimation(m_SW_Default.Action, m_SW_Default.Frames, m_SW_Default.FPS, m_SW_Default.Looped);
					m_SpriteImage.addAnimation(m_NE_Default.Action, m_NE_Default.Frames, m_NE_Default.FPS, m_NE_Default.Looped);
					m_SpriteImage.addAnimation(m_NW_Default.Action, m_NW_Default.Frames, m_NW_Default.FPS, m_NW_Default.Looped);
					break;
			}
			
			dispatchEvent(new Event(DONE));
			m_Loaded = true;
			setDir(m_CurrentDirection);	//For inital load this must come after m_DoneLoading = true;
			if (m_NewItem)
				m_SpriteImage.SetFilter(m_NewItemGlowEffect);
				
			m_AnimationLoader.removeEventListener(AnimationLoader.DONE, onAnimationDoneLoading);	
			m_AnimationLoader = null;
		}
		
		override public function setDir(dir:String):void
		{
			super.setDir(dir);
			if (m_Loaded)
				m_Game.Map.removeItem(this);
			if (m_CurrentDirection == IsoConstants.DIR_SE)
			{
				m_xOffset = m_SE_Default.xOffset;
				m_yOffset = m_SE_Default.yOffset;
				m_Rows = m_SE_Default.Rows;
				m_Cols = m_SE_Default.Cols
				m_SpriteImage.play(m_SE_Default.Action);
				
			}
			
			if ((m_CurrentDirection == IsoConstants.DIR_SW) && m_FacingCount > 1)
			{
				m_xOffset = m_SW_Default.xOffset;
				m_yOffset = m_SW_Default.yOffset;
				m_Rows = m_SW_Default.Rows;
				m_Cols = m_SW_Default.Cols
				m_SpriteImage.play(m_SW_Default.Action);
			}
			
			if ((m_CurrentDirection == IsoConstants.DIR_NW) && m_FacingCount > 2)
			{
				m_xOffset = m_NW_Default.xOffset;
				m_yOffset = m_NW_Default.yOffset;
				m_Rows = m_NW_Default.Rows;
				m_Cols = m_NW_Default.Cols
				m_SpriteImage.play(m_NW_Default.Action);
			}
			
			if ((m_CurrentDirection == IsoConstants.DIR_NE) && m_FacingCount > 2)
			{
				m_xOffset = m_NE_Default.xOffset;
				m_yOffset = m_NE_Default.yOffset;
				m_Rows = m_NE_Default.Rows;
				m_Cols = m_NE_Default.Cols
				m_SpriteImage.play(m_NE_Default.Action);
			}
			m_SpriteImage.x = m_ScreenX+ m_xOffset;
			m_SpriteImage.y = m_ScreenY + m_yOffset;
			if (m_Loaded && !m_NewItem && !m_InvItem)
				m_Game.Map.placeItem(this);
		}
		
		//render the art onto the screeen
		override public function render():void
		{
			if(m_Loaded)
				m_SpriteImage.render()	
		}
		//update the animation on the screen
		override public function update():void
		{
			if (m_Loaded)
				m_SpriteImage.update();	
		}
		
		//override mouse to not dispatch events
		override public function getMouseOver(x:int, y:int):Boolean
		{
			//the art is not loaded to who cares
			if (!m_SpriteImage) return false;
			if (!m_Enabled) return false;
			
			if (!m_MouseOver)
			{//the mouse was not over the image on the last frame
				if (x > m_SpriteImage.x && x < (m_SpriteImage.x + m_Width))
				{//mouse in within the bounding box width
					if (y > m_SpriteImage.y && y < (m_SpriteImage.y + m_Height))
					{//mouse is also in the bounding box heoght
						if (m_SpriteImage.pixels.hitTest(new Point(m_SpriteImage.x, m_SpriteImage.y), 0, new Point(x, y)))
						{//mouse is acutally over non transparent pixels
							m_MouseOver = true;
							onMouseOver();
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
							return true;
						}
					}
				}
			}else
			{//mouse was over on the last frame see if it still is
				if (x > m_SpriteImage.x && x < (m_SpriteImage.x + m_Width))
				{//mouse in within the bounding box width
					if (y > m_SpriteImage.y && y < (m_SpriteImage.y + m_Height))
					{//mouse is also in the bounding box height
						if (m_SpriteImage.pixels.hitTest(new Point(m_SpriteImage.x, m_SpriteImage.y), 0, new Point(x, y)))
						{//mouse is acutally over non transparent pixels
							updateToolTip();
							return true;
						}
					}
				}
				//mouse has left the image
				m_MouseOver = false;
				onMouseOut();
				if (m_ToolTipBubble)
				{
					if (m_ToolTipBubble.parent)
					{
						ToolTips.hide();
						//m_ToolTipBubble.parent.removeChild(m_ToolTipBubble);
						m_ToolTipBubble = null;
					}
				}
				return false;
			}
			//mouse was never here
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
				m_SpriteImage.SetFilter(m_GlowEffect);
		}
		
		//when the mouse enters add the glow effect
		override public function onMouseOut():void {
			if (m_EditMode && m_GlowEffect != null && m_NewItem == false)
				m_SpriteImage.RemoveFilter();
			
		}
		
		override public function addGlowEffect(glow:GlowFilter):void
		{
			if (m_NewItem)//dont double up
				m_NewItemGlowEffect = glow;
		}
		
		override public function removeGlowEffect():void
		{
			m_SpriteImage.RemoveFilter();
		}
	}

}