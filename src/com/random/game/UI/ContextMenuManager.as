package com.random.game.UI
{
	import com.random.iso.consts.GameConstants;
	import com.random.iso.GameObject;
	import com.random.iso.events.MenuEvent;
	import com.random.iso.items.DoorObject;
	import com.random.iso.items.StaticObject;
	import com.random.iso.items.SpriteObject;
	import com.random.iso.items.TrapObject;
	import com.random.iso.MobileObject;
	import com.random.iso.ui.ContextMenu;
	import com.random.iso.ui.ContextMenuItem;
	import com.random.game.RealmState;
	import LoAUIEvent;
	import LoAItem;
	import org.flixel.FlxState;
	import com.random.game.state.RealmBuilder;
	import com.random.game.objmanager.RealmManager;
	import com.random.game.UI.MsgBoxManager;
	import com.random.iso.consts.MsgConstants;
	import com.random.game.items.ChestObject;
	import org.flixel.FlxSound;
	import com.random.iso.items.DoorObject;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class ContextMenuManager 
	{
		public static const ITEM_MOVE:String = "ITEM_MOVE";
		public static const ITEM_PICKUP:String = "ITEM_PICKUP";
		public static const ITEM_SELL:String = "ITEM_SELL";
		public static const ITEM_COLLECT:String = "ITEM_COLLECT";
		public static const ITEM_ROTATE:String = "ITEM_ROTATE";
		public static const ITEM_NEXTROOM:String = "ITEM_NEXTROOM";

		private var m_StaticSingleMenu:ContextMenu;//menu for static objects
		private var m_StaticMultiMenu:ContextMenu;//menu for static objects
		
		private var m_MonsterMenu:ContextMenu;//menu for monsters
		private var m_TrapMenu:ContextMenu;//menu for traps
		private var m_DoorMenu:ContextMenu;//menu for Doors

		private var m_State:RealmState;//the game state that owns the menu
		
		private var m_SfxObjPickup:FlxSound;
		private var m_SfxObjRotate:FlxSound;
		private var m_SfxObjSell:FlxSound;
		private var m_SfxObjStore:FlxSound;
		
		public function ContextMenuManager(state:RealmState) 
		{
			var mnuList:Array = [];
			m_State = state;
			
			
			m_SfxObjPickup = new FlxSound();
			m_SfxObjPickup.loadEmbedded(object_pickup, false);
			m_SfxObjRotate = new FlxSound();
			m_SfxObjRotate.loadEmbedded(object_place, false);
			m_SfxObjSell = new FlxSound();
			m_SfxObjSell.loadEmbedded(purchase_confirm, false);
			m_SfxObjStore = new FlxSound();
			m_SfxObjStore.loadEmbedded(D2A_Character_Wear, false);
			
			//base menu items
			mnuList.push(new ContextMenuItem("Move", ITEM_MOVE));
			mnuList.push(new ContextMenuItem("Next Room", ITEM_NEXTROOM));
		
			//crate the Door menu
			m_DoorMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_DoorMenu.setPosition(-100, -100);
			m_DoorMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);
			
			//reset menu
			while (mnuList.length > 0)
				delete(mnuList.pop())
			
			mnuList.push(new ContextMenuItem("Move", ITEM_MOVE));
			mnuList.push(new ContextMenuItem("Pickup", ITEM_PICKUP));
			mnuList.push(new ContextMenuItem("Sell", ITEM_SELL));
			
			//crate the static menu
			m_StaticSingleMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_StaticSingleMenu.setPosition(-100, -100);
			m_StaticSingleMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);
			
			//create the trap menu
			m_TrapMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_TrapMenu.setPosition(-100, -100);
			m_TrapMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);
			
			
			mnuList.push(new ContextMenuItem("Rotate", ITEM_ROTATE));
			//crate the static menu
			m_StaticMultiMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_StaticMultiMenu.setPosition(-100, -100);
			m_StaticMultiMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);

			//create the monster menu
			m_MonsterMenu = new ContextMenu(mnuList, 0x00FFFFFF, 0, 0x00FFFFFF, 0x003399FF);
			m_MonsterMenu.setPosition(-100, -100);
			m_MonsterMenu.addEventListener(MenuEvent.ITEM_CLICKED, onItemClicked);
			
			
		}
		
		//rendenr the menu on the screen
		public function render():void {
			
			if (m_DoorMenu.Visible)
				m_DoorMenu.render();
			if (m_StaticSingleMenu.Visible)
				m_StaticSingleMenu.render();
			if (m_StaticMultiMenu.Visible)
				m_StaticMultiMenu.render();
			if (m_MonsterMenu.Visible)
				m_MonsterMenu.render();
			if (m_TrapMenu.Visible)
				m_TrapMenu.render();
		}
		
		//reset the menu after the level has been cleared
		public function reInit():void {
			m_DoorMenu.reInit();
			m_StaticSingleMenu.reInit();
			m_StaticMultiMenu.reInit();
			m_MonsterMenu.reInit();
			m_TrapMenu.reInit();
			
		}
		
		//see if the mouse is inside the menu
		public function MouseOver(x:int, y:int):Boolean  {
			
			
			
			if (m_DoorMenu.Visible)
			{
				if (m_DoorMenu.MouseOver(x, y))
					return true;
				else
					return m_DoorMenu.Visible;
			}
			
			
			if (m_StaticSingleMenu.Visible)
			{
				if (m_StaticSingleMenu.MouseOver(x, y))
					return true;
				else
					return m_StaticSingleMenu.Visible;
			}
			
			if (m_StaticMultiMenu.Visible)
			{
				if (m_StaticMultiMenu.MouseOver(x, y))
					return true;
				else
					return m_StaticMultiMenu.Visible;
			}
			
			
			if (m_MonsterMenu.Visible)
			{
				if (m_MonsterMenu.MouseOver(x, y))
					return true;
				else
					return m_MonsterMenu.Visible;
			}

			if (m_TrapMenu.Visible)
			{
				if (m_TrapMenu.MouseOver(x, y))
					return true;
				else
					return m_TrapMenu.Visible;
			}
			
			return false;
		}
		//if the mouse is inside the menu then call the correct click
		public function MouseClick(x:int, y:int):Boolean  {
		
			//the menu is visible then click the selected option
			if (m_DoorMenu.Visible)
			{
				if (m_DoorMenu.MouseClick(x, y))
					return true;
			}
			
			if (m_StaticMultiMenu.Visible)
			{
				if (m_StaticMultiMenu.MouseClick(x, y))
					return true;
			}
			if (m_StaticSingleMenu.Visible)
			{
				if (m_StaticSingleMenu.MouseClick(x, y))
					return true;
			}

			if (m_MonsterMenu.Visible)
			{
				if (m_MonsterMenu.MouseClick(x, y))
					return true;
			}
			if (m_TrapMenu.Visible)
			{
				if (m_TrapMenu.MouseClick(x, y))
					return true;
			}

			//menu is not visible so see what object is clicked and show the correct menue
			if (m_State.GameObjManager.CurrentSelected != null)
			{
				
					
				if (m_State.GameObjManager.CurrentSelected is DoorObject)
				{//show the static menu
					
					if (!m_DoorMenu.Visible)
					{
						m_DoorMenu.show(x, y, m_State.GameObjManager.CurrentSelected);
						return true;
					}	
				}

				
				if (m_State.GameObjManager.CurrentSelected is StaticObject)
				{//show the static menu
					
					if (m_State.GameObjManager.CurrentSelected.FacingCount > 1 && m_State.GameObjManager.CurrentSelected.Layer != 1)
					{
						
						if (!m_StaticMultiMenu.Visible)
						{
							m_StaticMultiMenu.show(x, y, m_State.GameObjManager.CurrentSelected);
							return true;
						}	
					}else
						if (!m_StaticSingleMenu.Visible)
						{
							m_StaticSingleMenu.show(x, y, m_State.GameObjManager.CurrentSelected);
							return true;
						}	
					
				}
				
				if (m_State.GameObjManager.CurrentSelected is SpriteObject)
				{//show the static menu
					
					if (m_State.GameObjManager.CurrentSelected.FacingCount > 1 && m_State.GameObjManager.CurrentSelected.Layer != 1)
					{
						if (!m_StaticMultiMenu.Visible)
						{
							m_StaticMultiMenu.show(x, y, m_State.GameObjManager.CurrentSelected);
							return true;
						}	
					}else
						if (!m_StaticSingleMenu.Visible)
						{
							m_StaticSingleMenu.show(x, y, m_State.GameObjManager.CurrentSelected);
							return true;
						}	
					
				}
				if (m_State.GameObjManager.CurrentSelected is MobileObject)
				{//show the monster menu
					if (!m_MonsterMenu.Visible)
					{
						m_MonsterMenu.show(x, y, m_State.GameObjManager.CurrentSelected);
						return true;
					}	
				}
				if (m_State.GameObjManager.CurrentSelected is TrapObject)
				{//show the trap menu
					if (!m_TrapMenu.Visible)
					{
						m_TrapMenu.show(x, y, m_State.GameObjManager.CurrentSelected);
						return true;
					}	
				}
				
			}
			//if the mouse is outside the menu then hide it
			m_DoorMenu.hide();
			m_StaticSingleMenu.hide();
			m_StaticMultiMenu.hide();
			m_MonsterMenu.hide();
			m_TrapMenu.hide();
			return false;
			
		}
		//menu item clicked event-
		private function onItemClicked(e:MenuEvent):void {
			
			var CurrentSelected:GameObject = GameObject(e.CurrentSelected);
			//menu action
			switch(e.Action)
			{
				case ITEM_MOVE: 
					m_SfxObjPickup.play();
					m_State.GameObjManager.moveItem(CurrentSelected);
				break;
				case ITEM_PICKUP:

					if (CurrentSelected is DoorObject)
					{
						MsgBoxManager.staticShowMessage(MsgConstants.DOORS);
						break; //TODO MSGBOX you dont own this yet jackass
					}
					if (CurrentSelected is ChestObject)
					{
						MsgBoxManager.staticShowMessage(MsgConstants.PICKUP_CHEST);
						break; //TODO MSGBOX you dont own this yet jackass
					}
					if (CurrentSelected.NewItem == true) 
					{
						MsgBoxManager.staticShowMessage(MsgConstants.DONT_OWN);
						break; //TODO MSGBOX you dont own this yet jackass
					}
					m_SfxObjStore.play();
					//give the item back to the UI
					var item:GameObject = CurrentSelected;
					var evt:LoAUIEvent = new LoAUIEvent(LoAUIEvent.ITEM_INV, true, false);;
					//trace(item.ItemID + "|" + item.CoinCost + "|" + item.BuckCost + "|" + item.ItemName + "|" + item.ItemType + "|" + item.ToolTip + "|" +item.IconFile);
					var evtitem:LoAItem = new LoAItem(item.ObjectID, 1, item.BuckCost, item.ItemName, item.ToolTip, item.ObjectType, "", item.IconFile, false,1,1,0,0);
					evt.setLoAItem(evtitem, null);
					m_State.dispatchEvent(evt);
					
					//remove the object from the game
					RealmManager(m_State.GameObjManager).storeItem(CurrentSelected);
					m_State.GameObjManager.removeItem(CurrentSelected);
				break;
				case ITEM_SELL:
					if (CurrentSelected is DoorObject)
					{
						MsgBoxManager.staticShowMessage(MsgConstants.DOORS);
						break; //TODO MSGBOX you dont own this yet jackass
					}
					if (CurrentSelected is ChestObject)
					{
						MsgBoxManager.staticShowMessage(MsgConstants.SELL_CHEST);
						break; //TODO MSGBOX you dont own this yet jackass
					}
					if (CurrentSelected.NewItem == true) 
										{
						MsgBoxManager.staticShowMessage(MsgConstants.DONT_OWN);
						break; //TODO MSGBOX you dont own this yet jackass
					}
					m_SfxObjSell.play();
					RealmManager(m_State.GameObjManager).sellItem(CurrentSelected);
					m_State.GameObjManager.removeItem(CurrentSelected);
				break;
				case ITEM_ROTATE:

					if (CurrentSelected is DoorObject) 
					{
						MsgBoxManager.staticShowMessage(MsgConstants.ROTATE);
						break; //TODO MSGBOX you dont own this yet jackass
					}	
					m_SfxObjRotate.play();
					m_State.GameObjManager.rotateItem(CurrentSelected);
				break;
				case ITEM_NEXTROOM:
					if (CurrentSelected is DoorObject) 	
						RealmManager(m_State.GameObjManager).changeRoom(DoorObject(CurrentSelected));
				break;
			}
		}
		
		
	}

}