package com.random.game.UI 
{
	
	import com.random.iso.consts.GameConstants;
	import com.random.iso.GameObject;
	import com.random.iso.events.MenuEvent;
	import com.random.iso.ui.ContextMenu;
	import com.random.iso.ui.ContextMenuItem;
	import dungeoneditor.DungeonMap;
	import com.random.iso.map.Room;
	import state.DungeonEditor;
	import org.flixel.FlxSound;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class DungeonMenuManager
	{
		
		public static const ITEM_MOVE:String = "ITEM_MOVE";
		public static const ITEM_EDIT:String = "ITEM_EDIT";
		public static const ITEM_SELL:String = "ITEM_SELL";
		public static const ITEM_CHEST:String = "ITEM_CHEST";
		public static const ITEM_START:String = "ITEM_START";
		public static const ITEM_RESET:String = "ITEM_RESET";
		
		

		
		private var m_DungeonMenu:ContextMenu = null;;//menu for Dungeon Rooms
		private var m_Dungeon:DungeonMap;
		private var m_DungeonEditor:DungeonEditor;
		
		private var m_SfxObjPickup:FlxSound;
		private var m_SfxObjSell:FlxSound;
		private var m_SfxSetTreasure:FlxSound;
		private var m_SfxSetStart:FlxSound;
		
		public function DungeonMenuManager(dun:DungeonMap, dunedit:DungeonEditor) 
		{
			m_Dungeon = dun;
			m_DungeonEditor = dunedit;
			initMenu();
			
			m_SfxObjPickup = new FlxSound();
			m_SfxObjPickup.loadEmbedded(object_pickup, false);
			m_SfxObjSell = new FlxSound();
			m_SfxObjSell.loadEmbedded(purchase_confirm, false);

			m_SfxSetTreasure = new FlxSound();
			m_SfxSetTreasure.loadEmbedded(set_treasure, false);

			m_SfxSetStart = new FlxSound();
			m_SfxSetStart.loadEmbedded(set_start, false);
			
		}

		
		public function initMenu():void 
		{
			var mnuList:Array = [];

			mnuList.push(new ContextMenuItem("Edit Room", ITEM_EDIT));
			mnuList.push(new ContextMenuItem("Move Room", ITEM_MOVE));
			mnuList.push(new ContextMenuItem("Sell Room", ITEM_SELL));
			mnuList.push(new ContextMenuItem("Set Start Room", ITEM_START));
			mnuList.push(new ContextMenuItem("Set Treasure Room", ITEM_CHEST));
			mnuList.push(new ContextMenuItem("Reset Room", ITEM_RESET));
			//crate the static menu
			m_DungeonMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_DungeonMenu.setPosition(-100, -100);
			m_DungeonMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);

		}
		
		//rendenr the menu on the screen
		public function render():void {
			
			if (m_DungeonMenu.Visible)
				m_DungeonMenu.render();
		}
		
		//reset the menu after the level has been cleared
		public function reInit():void {
			m_DungeonMenu.reInit();
		}
		
		//see if the mouse is inside the menu
		public function MouseOver(x:int, y:int):Boolean  {
			
			if (m_DungeonMenu.Visible)
			{
				if (m_DungeonMenu.MouseOver(x, y))
					return true;
				else
					return m_DungeonMenu.Visible;
			}
			
		
			return false;
		}
		//if the mouse is inside the menu then call the correct click
		public function MouseClick(x:int, y:int):Boolean  {
		
			//the menu is visible then click the selected option
			if (m_DungeonMenu.Visible)
			{
				if (m_DungeonMenu.MouseClick(x, y))
					return true;
			}

			//menu is not visible so see what object is clicked and show the correct menue
			if (m_Dungeon.CurrentSelected != null)
			{
				if (!m_DungeonMenu.Visible)
				{
					m_DungeonMenu.show(x, y, m_Dungeon.CurrentSelected);
					return true;
				}	
			}

			//if the mouse is outside the menu then hide it
			m_DungeonMenu.hide();
			return false;
			
		}
		
		public function hide():void 
		{
			m_DungeonMenu.hide();
		}
		
		//menu item clicked event-
		private function onItemClicked(e:MenuEvent):void {
			
			//menu action
			switch(e.Action)
			{
				case ITEM_MOVE: 
					m_SfxObjPickup.play();
					m_Dungeon.moveRoom(Room(e.CurrentSelected))
					break;
				case ITEM_EDIT:
					//trace("menu: " + Room(e.CurrentSelected).RoomID);
					m_DungeonEditor.editRoom(Room(e.CurrentSelected).RoomID)
					break;
				case ITEM_SELL:
					m_SfxObjSell.play();
					m_Dungeon.sellRoom(Room(e.CurrentSelected));
					break;
				case ITEM_CHEST:
					m_SfxSetTreasure.play();
					m_Dungeon.setChest(Room(e.CurrentSelected));
					break;
				case ITEM_START:
					m_SfxSetStart.play();
					m_Dungeon.setStart(Room(e.CurrentSelected));
					break;
				case ITEM_RESET:
					m_Dungeon.resetRoom(Room(e.CurrentSelected));
					break;
				
				
			}
		}
		
		
	}

}