package com.random.game.UI 
{
	import com.random.iso.consts.GameConstants;
	import com.random.iso.GameObject;
	import com.random.iso.events.MenuEvent;
	import com.random.iso.ui.ContextMenu;
	import com.random.iso.ui.ContextMenuItem;
	import com.random.game.objmanager.HomeManager;
	import com.random.game.items.ChestObject;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class ChestMenuManager
	{
		public static const ITEM_UPGRADE:String = "ITEM_UPGRADE";
		public static const ITEM_TILESET:String = "ITEM_TILESET";

		private var m_ChestHomeMenu:ContextMenu = null;//menu for Realm Chest
		private var m_Game:HomeManager;//the game state that owns the menu
		public function ChestMenuManager(game:HomeManager) 
		{
			var mnuList:Array = [];
			m_Game = game;
			
			//trace(m_Game.KeeperStatus);
			mnuList.push(new ContextMenuItem("Upgrade Chest", ITEM_UPGRADE));
			mnuList.push(new ContextMenuItem("Change Tileset", ITEM_TILESET));
			
			//crate the static menu
			m_ChestHomeMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_ChestHomeMenu.setPosition(-100, -100);
			m_ChestHomeMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);
		}
	
		
		//rendenr the menu on the screen
		public function render():void {
			
			if (m_ChestHomeMenu.Visible)
				m_ChestHomeMenu.render();
		}
		
		//see if the mouse is inside the menu
		public function MouseOver(x:int, y:int):Boolean  {
			
			if (m_ChestHomeMenu.Visible)
			{
				if (m_ChestHomeMenu.MouseOver(x, y))
					return true;
				else
					return m_ChestHomeMenu.Visible;
			}
			
		
			return false;
		}
		//if the mouse is inside the menu then call the correct click
		public function MouseClick(x:int, y:int):Boolean  {
		
			//the menu is visible then click the selected option
			if (m_ChestHomeMenu.Visible)
			{
				if (m_ChestHomeMenu.MouseClick(x, y))
					return true;
			}

			//menu is not visible so see what object is clicked and show the correct menue
			if (m_Game.CurrentSelected != null)
			{
				if (m_Game.CurrentSelected is ChestObject)
				{//show the static menu
					
						if (!m_ChestHomeMenu.Visible)
						{
							m_ChestHomeMenu.show(x, y, m_Game.CurrentSelected);
							return true;
						}	
				}
				
				
			}
			//if the mouse is outside the menu then hide it
			m_ChestHomeMenu.hide();
			return false;
			
		}
		
		public function hide():void 
		{
			m_ChestHomeMenu.hide();
		}
		
		//menu item clicked event-
		private function onItemClicked(e:MenuEvent):void {
			
			//menu action
			switch(e.Action)
			{
				case ITEM_UPGRADE:
				    //give the item back to the UI
					var item:GameObject = GameObject(e.CurrentSelected);
					var evt:LoAUIEvent = new LoAUIEvent(LoAUIEvent.ITEM_INV, true, false);;
					//trace(item.ItemID + "|" + item.CointCost + "|" + item.BuckCost + "|" + item.ItemName + "|" + item.ToolTip + "|" +item.IconFile);
					var evtitem:LoAItem = new LoAItem(item.ObjectID, item.CoinCost, item.BuckCost, item.ItemName,item.ToolTip, item.ObjectType, "", item.IconFile, true);
					evt.setLoAItem(evtitem, null);
					//m_State.dispatchEvent(evt);
					
				break;
				case ITEM_TILESET:
				break;
			}
		}
		
	}

}