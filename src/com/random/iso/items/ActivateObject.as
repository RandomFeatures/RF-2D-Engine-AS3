package com.random.iso.items 
{
	import com.random.iso.consts.AnimationConstants;
	import com.random.iso.GameObjectManager;
	import com.random.iso.consts.IsoConstants;
	import com.random.iso.consts.GameConstants;
	import com.random.iso.utils.AnimationLoader;
	import flash.filters.GlowFilter;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class ActivateObject extends SpriteObject
	{
		
		protected var m_SE_Activate:FacingProp;
		protected var m_SW_Activate:FacingProp;
		protected var m_NE_Activate:FacingProp;
		protected var m_NW_Activate:FacingProp;
		private var m_Status:String = "closed";
		
		
		
		
		public function ActivateObject(editMode:Boolean, game:GameObjectManager) 
		{
			if (m_GlowEffect == null)
			{
				if(editMode)
					m_GlowEffect = new GlowFilter(0x00009900);
				else	
					m_GlowEffect = new GlowFilter(0x00ECD672);
					
				m_GlowEffect.inner = true;
			}else 
				m_GlowEffect.inner = true;

			super(editMode, game);
			
		}
		
		public function get Status():String { return m_Status; }
		
		//load the static from the xml data
		override public function loadFromXML(xml:XML):void
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
					m_NE_Activate = loadFacingProperties(xml.child("NE_Activate"), AnimationConstants.NE_ACTIVATE);
					m_NW_Default = loadFacingProperties(xml.child("NW_Default"), AnimationConstants.NW_DEFAULT);
					m_NW_Activate = loadFacingProperties(xml.child("NW_Activate"), AnimationConstants.NW_ACTIVATE);
				case 2:
					m_SW_Default = loadFacingProperties(xml.child("SW_Default"), AnimationConstants.SW_DEFAULT);
					m_SW_Activate = loadFacingProperties(xml.child("SW_Activate"), AnimationConstants.SW_ACTIVATE);
				case 1:
					m_SE_Default = loadFacingProperties(xml.child("SE_Default"), AnimationConstants.SE_DEFAULT);
					m_SE_Activate = loadFacingProperties(xml.child("SE_Activate"), AnimationConstants.SE_ACTIVATE);
			}
			
			//default settings for SE			
			m_xOffset = m_SE_Default.xOffset;
			m_yOffset = m_SE_Default.yOffset;
			m_Rows = m_SE_Default.Rows;
			m_Cols = m_SE_Default.Cols;
			
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
				m_AnimationLoader.loadFile(GameConstants.RESOURCE_BASE + url, false);
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
		
		
		//The image has downloaded from the sever
		private function onAnimationDoneLoading(e:Event):void {
			
			m_SpriteImage.loadExtGraphic(m_AnimationLoader.SpriteImage, m_FileName, false, true, false, m_Width, m_Height, true);
			
			m_Width = m_SpriteImage.width;
			m_Height = m_SpriteImage.height;
			
			switch (m_FacingCount)
			{
				case 1:
					m_SpriteImage.addAnimation(m_SE_Default.Action, m_SE_Default.Frames, m_SE_Default.FPS, m_SE_Default.Looped);
					m_SpriteImage.addAnimation(m_SE_Activate.Action, m_SE_Activate.Frames, m_SE_Activate.FPS, m_SE_Activate.Looped);
					break;
				case 2:
					m_SpriteImage.addAnimation(m_SE_Default.Action, m_SE_Default.Frames, m_SE_Default.FPS, m_SE_Default.Looped);
					m_SpriteImage.addAnimation(m_SE_Activate.Action, m_SE_Activate.Frames, m_SE_Activate.FPS, m_SE_Activate.Looped);
					m_SpriteImage.addAnimation(m_SW_Default.Action, m_SW_Default.Frames, m_SW_Default.FPS, m_SW_Default.Looped);
					m_SpriteImage.addAnimation(m_SW_Activate.Action, m_SW_Activate.Frames, m_SW_Activate.FPS, m_SW_Activate.Looped);

					break;
				case 4:
					//m_SE_Default.Frames
					m_SpriteImage.addAnimation(m_SE_Default.Action, m_SE_Default.Frames, m_SE_Default.FPS, m_SE_Default.Looped);
					m_SpriteImage.addAnimation(m_SE_Activate.Action, m_SE_Activate.Frames, m_SE_Activate.FPS, m_SE_Activate.Looped);
					m_SpriteImage.addAnimation(m_SW_Default.Action, m_SW_Default.Frames, m_SW_Default.FPS, m_SW_Default.Looped);
					m_SpriteImage.addAnimation(m_SW_Activate.Action, m_SW_Activate.Frames, m_SW_Activate.FPS, m_SW_Activate.Looped);

					m_SpriteImage.addAnimation(m_NE_Default.Action, m_NE_Default.Frames, m_NE_Default.FPS, m_NE_Default.Looped);
					m_SpriteImage.addAnimation(m_NE_Activate.Action, m_NE_Activate.Frames, m_NE_Activate.FPS, m_NE_Activate.Looped);
					m_SpriteImage.addAnimation(m_NW_Default.Action, m_NW_Default.Frames, m_NW_Default.FPS, m_NW_Default.Looped);
					m_SpriteImage.addAnimation(m_NW_Activate.Action, m_NW_Activate.Frames, m_NW_Activate.FPS, m_NW_Activate.Looped);

					break;
			}
			
			dispatchEvent(new Event(DONE));
			m_Loaded = true;
			setDir(m_CurrentDirection);//For inital load this must come after m_DoneLoading = true;	
			m_AnimationLoader.removeEventListener(AnimationLoader.DONE, onAnimationDoneLoading);	
			m_AnimationLoader = null;
		
		}
		
		
		virtual public function activate():void {
			
			m_Status = "open";

			switch (m_CurrentDirection)
			{
				case IsoConstants.DIR_SE:
					m_xOffset = m_SE_Activate.xOffset;
					m_yOffset = m_SE_Activate.yOffset;
					m_Rows = m_SE_Activate.Rows;
					m_Cols = m_SE_Activate.Cols
					m_SpriteImage.play(m_SE_Activate.Action);
				break;
				case IsoConstants.DIR_SW:
					m_xOffset = m_SW_Activate.xOffset;
					m_yOffset = m_SW_Activate.yOffset;
					m_Rows = m_SW_Activate.Rows;
					m_Cols = m_SW_Activate.Cols
					m_SpriteImage.play(m_SW_Activate.Action);
				break;
				case IsoConstants.DIR_NE:
					m_xOffset = m_NE_Activate.xOffset;
					m_yOffset = m_NE_Activate.yOffset;
					m_Rows = m_NE_Activate.Rows;
					m_Cols = m_NE_Activate.Cols
					m_SpriteImage.play(m_NE_Activate.Action);
				break;
				case IsoConstants.DIR_NW:
					m_xOffset = m_NW_Activate.xOffset;
					m_yOffset = m_NW_Activate.yOffset;
					m_Rows = m_NW_Activate.Rows;
					m_Cols = m_NW_Activate.Cols
					m_SpriteImage.play(m_NW_Activate.Action);
				break;
			}
		}
		//when the mouse leaves remove the glow effect
		override public function onMouseOver():void {
			
			if ((m_GlowEffect != null) && (m_Status == "closed"))
			{
				m_SpriteImage.SetFilter(m_GlowEffect);
			}
		}
		
		//when the mouse enters add the glow effect
		override public function onMouseOut():void {
			
			if (m_GlowEffect != null)
				m_SpriteImage.RemoveFilter();
			
		}
	}

}