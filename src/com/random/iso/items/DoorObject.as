package com.random.iso.items 
{
	import com.random.iso.items.StaticObject;
	import com.random.iso.GameObjectManager;
	import flash.filters.GlowFilter;
	import com.random.iso.consts.IsoConstants;
	import com.random.iso.ui.ToolTips;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class DoorObject extends StaticObject
	{
		
		private var m_link:int = 0;
		private var m_type:int = 0;
		public static var m_GlowEffect:GlowFilter;
		
		public function DoorObject(editMode:Boolean, game:GameObjectManager) 
		{
			if (m_GlowEffect == null)
			{
				if (editMode)
				{
					m_GlowEffect = new GlowFilter(0x00009900);
					m_GlowEffect.inner = true;
				}	
				//else	
				//	m_GlowEffect = new GlowFilter(0x00FF0000);
			}else
				m_GlowEffect.inner = true;
			
			super(editMode, game);
		}
		
		public function get LinkRoom():int { return m_link; }
		public function get DoorType():int { return m_type; }
		
				//load the static from the xml data
		override public function loadFromXML(xml:XML):void
		{
			m_link = int(xml.@link);
			m_type = int(xml.@type);
			//trace(xml);
			super.loadFromXML(xml);
			if (!m_EditMode)
				ToolTip = "DOOR: Left click to enter this passageway.";
			else
				ToolTip = "DOOR: Left click to move this item or load the next room.";
		}
		
		
		//when the mouse leaves remove the glow effect
		override public function onMouseOver():void {
			
			if (m_GlowEffect != null)
			{
				m_StaticImage.SetFilter(m_GlowEffect);
			}
			
		}
		
		//when the mouse enters add the glow effect
		override public function onMouseOut():void {
			
			if (m_GlowEffect != null)
				m_StaticImage.RemoveFilter();
			
		}
		
		//set the object positon in the world and on the screen
		override public function setPosition(posX:int, posY:int):void {
			super.setPosition(posX, posY);
			
			m_StaticImage.alpha = 1;
			if (m_type == 0)
			{
				if ((posY != 0) && (m_CurrentDirection == IsoConstants.DIR_NE))
					m_StaticImage.alpha = 0.50;
				if ((m_CurrentDirection == IsoConstants.DIR_NW) && (posX != 0))
					m_StaticImage.alpha = 0.50;
			}
			else
			{
				if ((posX != m_Game.Map.Columns-1) && (m_CurrentDirection == IsoConstants.DIR_SE))
					m_StaticImage.alpha = 0.50;
				if ((m_CurrentDirection == IsoConstants.DIR_SW) && (posY !=  m_Game.Map.Rows-1))
					m_StaticImage.alpha = 0.50;
			}
			
			m_StaticImage.update();
		}
		
	}

}