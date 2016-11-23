package  com.random.game.objmanager
{
	import com.random.iso.map.IsoStructure;
	import com.random.game.MyRealmObjManager;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import com.random.iso.GameObject;
	import com.random.iso.MobileObject;
	import com.random.iso.items.StaticObject;
	import com.random.iso.items.SpriteObject;
	import com.random.iso.items.ActivateObject;
	import com.random.iso.items.TrapObject;
	import com.random.iso.consts.GameConstants;
	import consts.RealmConsts;
	import com.random.iso.consts.MsgConstants;
	import com.random.game.UI.MsgBoxManager;
	import flash.utils.setTimeout;
	import com.random.game.consts.Globals;
	import org.flixel.FlxSound;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class RealmManager extends MyRealmObjManager
	{
		private var m_SfxConfirm:FlxSound;
		
		public function RealmManager() 
		{
			super();
			
			m_SfxConfirm = new FlxSound();
			m_SfxConfirm.loadEmbedded(purchase_confirm, false);
		}
		
		override public function cleanUp():void {
			if (NewItem != null)
				removeItem(NewItem, false);
			cancelNewItem();
			cancelPendingMapStructure();
			m_SfxConfirm.stop();
			m_SfxConfirm.destroy();
			m_SfxConfirm = null;
			super.cleanUp();
		}
		
		//mouse click for edit mode. 
		override public function onClick(mousex:int,mousey:int):void {

			if (m_ItemBeingDragged != null)
			{
				if (m_Map.placementTest(m_ItemBeingDragged))
				{
					placeDraggedItem();
					
					if (NewItem != null && NewItem.CoinCost > 0)
					{//buy it on inital placement if it cost coins
						showPurchaseItem(NewItem);
						buyItem(); 
						m_SfxConfirm.play();
					}
					
					
				}else m_MsgBoxManager.showMessageBox(MsgConstants.DRAG_PLACE);
			}else
			{//clicked object
				if (m_CurrentSelected)
					m_CurrentSelected.onMouseClick(mousex, mousey);
			}

		}	
		
		public function cancelPendingMapStructure():void {
			
			if (m_Map.getNewStructure() != null) 
				m_Map.cancelStructure();
		}
		
		
		public function checkPendingMapStructure():IsoStructure {
			
			return  m_Map.getNewStructure();
		}
		
		//override protected function parseRealmObjects(xml:XML):void { }
		public function buyMapStructure():void
		{
			var struct:IsoStructure = m_Map.getNewStructure();
			var url:String;
			
			if (struct != null)
			{
				
				if (struct.BuckCost > 0)
					AvatarStats(m_Stats).loseBucks(struct.BuckCost);
				else
					if (struct.CoinCost > 0)
						AvatarStats(m_Stats).loseGold(struct.CoinCost);
				
				url = GameConstants.RESOURCE_BASE + RealmConsts.BUYITEM + "&itemid=" + struct.ItemID + "&roomid=" + m_Realm.CurrentRoom.RoomID + "&gridx=0&gridy=0&objtype=" + struct.ItemType + "&objid=" + struct.ItemID + "&dir=SE";
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, onBuyStructureComplete);
				xmlLoader.load(new URLRequest(url));	
			}
		}
		
		private function onBuyStructureComplete(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			
			var status:String = xml.header.status;
			var item:GameObject; 
			
			//update the item id or remove the item from the game
			if (status == "Failure")
			{//failed because... well no money
				m_MsgBoxManager.showBuyBuckBroke();
				m_Map.cancelStructure();
			}else
			if (status == "Success")
			{//success!!
				m_Map.saveStructure();	
				Globals.REALM_XML = "";
			}
			
		}
		
		private function placeDraggedItem():void {
			if (m_Map.placementTest(m_ItemBeingDragged))
			{
				m_ItemBeingDragged.InvItem = false;
				if (m_ItemBeingDragged is StaticObject)
					m_Map.placeItem(m_ItemBeingDragged);
				else if (m_ItemBeingDragged is SpriteObject)
					m_Map.placeItem(m_ItemBeingDragged);
				else
					m_Map.placeMonster(m_ItemBeingDragged);
				
				saveItem(m_ItemBeingDragged);
				m_DragGrid.Enabled = false;
				m_ItemBeingDragged = null;
				sortLifeLayer();
			}
		}
		
		public function buyItem():void
		{
			var url:String;
			if (m_NewItem != null)
			{
				
				if (m_ItemBeingDragged != null)
				{//item is still being dragged
					if (m_Map.placementTest(m_ItemBeingDragged))
					{
						placeDraggedItem();
					}else 
					{	
						removeItem(NewItem, false);
						cancelNewItem();
						m_MsgBoxManager.showMessageBox(MsgConstants.DRAG_BUY);
						return;
					}
				}
				
				m_NewItem.removeGlowEffect();
				m_NewItem.NewItem = false;
				m_DragGrid.Enabled = false;
				m_ItemBeingDragged = null;
				url = GameConstants.RESOURCE_BASE + RealmConsts.BUYITEM + "&itemid=" + m_NewItem.OwnerItemId + "&roomid=" + m_Realm.CurrentRoom.RoomID + "&gridx=" + m_NewItem.xPos + "&gridy=" + m_NewItem.yPos + "&objtype=" + m_NewItem.ObjectType + "&objid=" + m_NewItem.ObjectID + "&dir=" + directionLookup(m_NewItem.Dir);
				m_NewItem = null; 
				//trace(url);
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, onBuyItemComplete);
				xmlLoader.load(new URLRequest(url));
			
			}
		}
				
		private function onBuyItemComplete(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			
			var status:String = xml.header.status;
			var item:GameObject; 
			
			//update the item id or remove the item from the game
			if (status == "Failure")
			{//failed because... well no money
				
				m_MsgBoxManager.showBuyBuckBroke();
				var itemid:String = xml.dataset.row.fieldlist.field.(@name == "SystemMessage");
				for each (item in m_MasterObjList)
				{
					if (item.OwnerItemId == itemid)
					{
						removeItem(item, false);
						break;
					}
				}	
			}else
			if (status == "Success")
			{//success!!
				var oldID:String = xml.dataset.row.fieldlist.field.(@name == "itemID");
				var newID:String = xml.dataset.row.fieldlist.field.(@name == "RtnItemID");
				var xpReward:int = int(xml.dataset.row.fieldlist.field.(@name == "xpreward"));
				for each (item in m_MasterObjList)
				{
					if (item.OwnerItemId == oldID)
					{
						item.OwnerItemId = newID;
						if (xpReward > 0)
							showItemGainXp(item, xpReward);
						break;
					}
				}	
				//Globals.ROOM_XML = this.toXML();
				Globals.REALM_XML = "";
				
				AvatarStats.loadFromStatsXML(xml);
				m_Stats.updateUI();
			}
			
		}
		//save changes to the room item
		public function saveItem(item:GameObject):void
		{
			var url:String;
			
			if (item != NewItem)
			{
				url = GameConstants.RESOURCE_BASE + RealmConsts.SAVEITEM + "&itemid=" + item.OwnerItemId + "&roomid=" + m_Realm.CurrentRoom.RoomID + "&gridx=" + item.xPos + "&gridy=" + item.yPos + "&objtype=" + item.ObjectType + "&objid=" + item.ObjectID + "&dir=" + directionLookup(item.Dir);
				//trace(url);
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.load(new URLRequest(url));
				//Globals.ROOM_XML = this.toXML();
				Globals.REALM_XML = "";
				notifySaving();
			}
		}
		//place room item from the player inventory
		public function addItem(item:GameObject):void
		{
			var url:String;
			url = GameConstants.RESOURCE_BASE + RealmConsts.ADDITEM + "&itemid=" + item.OwnerItemId + "&roomid=" + m_Realm.CurrentRoom.RoomID + "&gridx=" + item.xPos + "&gridy=" + item.yPos + "&objtype=" + item.ObjectType + "&objid=" + item.ObjectID + "&dir=" + directionLookup(item.Dir);
			
			if (m_NewItem)
			{
				m_NewItem.removeGlowEffect();
				m_NewItem.NewItem = false;
				m_NewItem = null;
			}
			m_DragGrid.Enabled = false;
			m_ItemBeingDragged = null;
			
			
			//trace(url);
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onBuyItemComplete);
			xmlLoader.load(new URLRequest(url));
			//Globals.ROOM_XML = this.toXML();
			Globals.REALM_XML = "";
			notifySaving();
		}
		//sell the room item
		public function sellItem(item:GameObject):void
		{
			var url:String;
			url = GameConstants.RESOURCE_BASE + RealmConsts.SELLITEM + "&itemid=" + item.OwnerItemId + "&roomid=" + m_Realm.CurrentRoom.RoomID;
			//trace(url);
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.load(new URLRequest(url));
			
			//Globals.ROOM_XML = this.toXML();
			Globals.REALM_XML = "";
			//get an update to the cash for the sell
			setTimeout(serverRequestStats, 1000);
			
		}
		//store the room item in the player inventory
		public function storeItem(item:GameObject):void
		{
			var url:String;
			url = GameConstants.RESOURCE_BASE + RealmConsts.STOREITEM + "&itemid=" + item.OwnerItemId + "&roomid=" + m_Realm.CurrentRoom.RoomID;
			//trace(url);
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.load(new URLRequest(url));
			//Globals.ROOM_XML = this.toXML();
			Globals.REALM_XML = "";
			notifySaving();
		}

		override public function rotateItem(item:GameObject):void {
			
			super.rotateItem(item);
			
			saveItem(item);
		}
		
		
	}

}