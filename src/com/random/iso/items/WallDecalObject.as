package com.random.iso.items 
{
	import com.random.iso.GameObjectManager;
	import com.random.iso.items.StaticObject;
	import com.random.iso.consts.IsoConstants;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class WallDecalObject extends StaticObject
	{
		
				
		public function WallDecalObject(editMode:Boolean, game:GameObjectManager) 
		{
			super(editMode, game);
		}

				
		//set the object positon in the world and on the screen
		override public function setPosition(posX:int, posY:int):void {
			super.setPosition(posX, posY);
			
			m_StaticImage.alpha = 1;
			
			if (m_PosX == 0)
			{
				setDir(IsoConstants.DIR_SE)
			}else if (m_PosY == 0)
				setDir(IsoConstants.DIR_SW)
			
		   if (m_PosX != 0 && m_PosY != 0)
			 m_StaticImage.alpha = 0.50;
		}
		
				
		
	}

}