package com.random.iso.items 
{
	import com.random.iso.GameObjectManager;
	import com.random.iso.items.SpriteObject;
	import com.random.iso.consts.IsoConstants;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class SpriteDecalObject extends SpriteObject
	{
		
		public function SpriteDecalObject(editMode:Boolean, game:GameObjectManager) 
		{
			super(editMode, game);
		}
	
		//set the object positon in the world and on the screen
		override public function setPosition(posX:int, posY:int):void {
			super.setPosition(posX, posY);
			m_SpriteImage.alpha = 1;
			
			if (m_PosX == 0)
			{
				setDir(IsoConstants.DIR_SE)
			}else if (m_PosY == 0)
				setDir(IsoConstants.DIR_SW)
			
			if (m_PosX != 0 && m_PosY != 0)
			 m_SpriteImage.alpha = 0.50;
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
			
			m_SpriteImage.x = m_ScreenX+ m_xOffset;
			m_SpriteImage.y = m_ScreenY + m_yOffset;
			if (m_Loaded && !m_NewItem && !m_InvItem)
				m_Game.Map.placeItem(this);
		}
		
	}

}