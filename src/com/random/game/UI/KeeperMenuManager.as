package com.random.game.UI 
{
	import com.random.iso.consts.GameConstants;
	import com.random.iso.GameObject;
	import com.random.iso.events.MenuEvent;
	import com.random.iso.ui.ContextMenu;
	import com.random.iso.ui.ContextMenuItem;
	import objmanager.HomeManager;
	import items.KeeperObject;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class KeeperMenuManager
	{
		public static const ITEM_CLEAN:String = "ITEM_MOVE";
		public static const ITEM_UPGRADE:String = "ITEM_UPGRADE";
		public static const ITEM_COLLECT:String = "ITEM_COLLECT";

		
		private var m_KeepIdleMenu:ContextMenu = null;;//menu for Keeper objects
		private var m_Game:HomeManager;//the game state that owns the menu
		private var m_KeeperStatus:int = 0;
		public function KeeperMenuManager(game:HomeManager) 
		{
			m_Game = game;
			initMenu();
		}

		
		public function initMenu():void 
		{
			var mnuList:Array = [];
			m_KeeperStatus = m_Game.KeeperStatus;
			//trace(m_Game.KeeperStatus);
			if (m_KeeperStatus == 0)
				mnuList.push(new ContextMenuItem("Clean Dungeon", ITEM_CLEAN));
			if (m_KeeperStatus == 2)
				mnuList.push(new ContextMenuItem("Collect Gold", ITEM_COLLECT));
  					
			//mnuList.push(new ContextMenuItem("Upgrade Keeper", ITEM_UPGRADE));
			
			if (m_KeepIdleMenu != null)
			{
				m_KeepIdleMenu.cleanup();
				m_KeepIdleMenu = null;
			}
			//crate the static menu
			m_KeepIdleMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_KeepIdleMenu.setPosition(-100, -100);
			m_KeepIdleMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);

		}
		
		//rendenr the menu on the screen
		public function render():void {
			
			if (m_KeepIdleMenu.Visible)
				m_KeepIdleMenu.render();
		}
		
		//reset the menu after the level has been cleared
		public function reInit():void {
			m_KeepIdleMenu.reInit();
		}
		
		//see if the mouse is inside the menu
		public function MouseOver(x:int, y:int):Boolean  {
			
			if (m_KeepIdleMenu.Visible)
			{
				if (m_KeepIdleMenu.MouseOver(x, y))
					return true;
				else
					return m_KeepIdleMenu.Visible;
			}
			
		
			return false;
		}
		//if the mouse is inside the menu then call the correct click
		public function MouseClick(x:int, y:int):Boolean  {
			//the menu is visible then click the selected option
			if (m_KeepIdleMenu.Visible)
			{
				if (m_KeepIdleMenu.MouseClick(x, y))
					return true;
			}
			//menu is not visible so see what object is clicked and show the correct menue
			if (m_Game.CurrentSelected != null)
			{
				if (m_Game.CurrentSelected is KeeperObject)
				{//show the static menu
						if (!m_KeepIdleMenu.Visible)
						{
							if (m_Game.KeeperStatus != m_KeeperStatus)
								initMenu();
							m_KeepIdleMenu.show(x, y, m_Game.CurrentSelected);
							return true;
						}	
				}
			}
			//if the mouse is outside the menu then hide it
			m_KeepIdleMenu.hide();
			return false;
			
		}
		
		public function hide():void 
		{
			m_KeepIdleMenu.hide();
		}
		
		//menu item clicked event-
		private function onItemClicked(e:MenuEvent):void {
			
			//menu action
			switch(e.Action)
			{
				case ITEM_CLEAN: 
					m_Game.cleanRealm();
				break;
				case ITEM_UPGRADE:
				    //give the item back to the UI
					var item:GameObject = GameObject(e.CurrentSelected);
				break;
				case ITEM_COLLECT:
					m_Game.collectKeeper();
				break;
			}
		}
		
	}

}