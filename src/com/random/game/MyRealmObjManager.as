package com.random.game
{
	import com.random.iso.GameObjectManager;
	import com.random.iso.items.DoorObject;
	import com.random.iso.map.Room;
	import com.random.iso.ui.MessageBox;
	import com.random.iso.ui.QuestionBox;
	import flash.events.Event;
	import com.random.iso.ui.BubbleText;
	import com.random.iso.GameObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.MouseEvent;
	import com.random.iso.map.Realm;
	import com.random.game.AvatarStats;
	import com.random.iso.MobileObject;
	import com.random.iso.items.StaticObject;
	import com.random.iso.items.SpriteObject;
	import com.random.iso.items.ActivateObject;
	import com.random.iso.items.TrapObject;
	import com.random.game.consts.RealmConsts;
	import com.random.game.items.ChestObject;
	import com.random.iso.characters.monsters.MonsterCharacter;
	import com.random.iso.consts.*;
	import com.random.iso.characters.avatar.LayerCharacter;
	import org.flixel.FlxG;
	import com.random.game.UI.MsgBoxManager;
	import com.random.iso.ui.ToolTips;
	import flash.events.TimerEvent;
	import com.random.game.events.UpdateUIEvent;
	import com.random.game.consts.Globals;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class MyRealmObjManager extends GameObjectManager
	{
		
		protected var m_Realm:Realm;
		protected var m_BubbleTextList:Array = [];//list of active bubble text objects
		protected var m_StartRoom:String = RealmConsts.ROOM_START;
		protected var m_RealmXML:XML;
		protected var m_AutoLoadRoom:Boolean = false;
		private var m_onRoomLoadCallback:Function = null;
		protected var m_AvatartStart:int = 0;
		protected var m_DefeatTimer:int = 0;
		protected var m_PlayerDefeated:Boolean = false;
		protected var m_PathtoDoor:DoorObject = null;
		protected var m_PathToMainChest:ChestObject = null;
		protected var m_PathToActivateObj:ActivateObject = null;
		protected var m_Adventuring:Boolean = false;
		protected var m_MsgBoxManager:MsgBoxManager = null;
		private var xmlStatsLoader:URLLoader;
		protected var m_AvatarLastDoor:int = 0;
		public function MyRealmObjManager() 
		{
			m_MsgBoxManager = new MsgBoxManager();
			m_PlayerDefeated = false;
			super()
		}
		
		public function get RealmObj():Realm { return m_Realm; }
		public function get MessageBoxManager():MsgBoxManager { return m_MsgBoxManager; }
		
		override public function cleanUp():void {
			super.cleanUp()
			m_Realm = null;
			m_MsgBoxManager.hideAll();
			ToolTips.hide();
			m_MsgBoxManager.destroy();
			m_MsgBoxManager = null;
			while (m_BubbleTextList.length > 0)
				delete(m_BubbleTextList.pop())
			
		}
		
		override protected function init():void {
			super.init();
		}
		
		public function setRoomLoadCallback(onRoomLoadCallback:Function):void {
			m_onRoomLoadCallback = onRoomLoadCallback;
		}
		
		public function SetStartRoom(room:String):void
		{
			m_StartRoom = room;
		}
		
		//get a room xml file from a URL
		public function loadRealmURL(url:String, loadroom:Boolean):void
		{
			//trace(url);
			m_AutoLoadRoom = loadroom;
			m_Loading = true;
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onLoadRealmXML);
			xmlLoader.load(new URLRequest(url));	
		}
		
		//XML Loader complete event
		private function onLoadRealmXML(e:Event):void 
		{
			m_Loading = true;
			//trace(e.target.data);
			if (e.target.data != "")
			{
				try {
					m_RealmXML = XML(e.target.data);
					if (m_RealmXML.header.status == "Success")
					{
						if (!m_Adventuring)
							Globals.REALM_XML = e.target.data;
						parseRealmObjects(m_RealmXML);
					}
				}catch(errObject:Error) 
				{
					//trace(e.target.data);
				}
			}
		}
		
		public function loadRealmXML(loadroom:Boolean):void
		{
			m_AutoLoadRoom = loadroom;
			m_Loading = true;
			m_RealmXML = XML(Globals.REALM_XML);
			parseRealmObjects(m_RealmXML);
		}
		
		//track the mouse around the game screen
		override public function onMouseMove(mousex:int, mousey:int):void {
			super.onMouseMove(mousex, mousey);		
		}
		
		virtual protected function parseRealmObjects(xml:XML):void 
		{ 
			m_Realm = new Realm();
			m_Realm.parseRealmXML(xml);
			m_Realm.CurrentRoomID = m_Realm.StartRoomID;
			FlxG.log("RealmID: " + m_Realm.RealmID);
			if (m_AutoLoadRoom) loadInitalRoom(); 			
		}
		
		public function loadInitalRoom():void
		{
			//trace(m_StartRoom);
			if (m_StartRoom == RealmConsts.ROOM_CHEST)
			{
				var chestroom:Room = m_Realm.getRoom(String(m_Realm.ChestRoomID));
				m_Realm.CurrentRoom = chestroom;
				parseRoom(chestroom.Data);
				parseChest(m_RealmXML);
			}
			else if (m_StartRoom == RealmConsts.ROOM_START) {
				var startroom:Room = m_Realm.getRoom(String(m_Realm.StartRoomID));
				m_Realm.CurrentRoom = startroom;
				parseRoom(startroom.Data);
			}
			else
			{
				var room:Room = m_Realm.getRoom(m_StartRoom);
				m_Realm.CurrentRoom = room;
				
				parseRoom(room.Data);
				//in the chest room so load the chest
				if (int(m_StartRoom) == m_Realm.ChestRoomID)
					parseChest(m_RealmXML);
			}
			
			if (m_onRoomLoadCallback != null) m_onRoomLoadCallback();
		}
		
		virtual public function changeRoom(door:DoorObject):void {
			
			m_MapReady = false;
			m_MapRenderReady = false;
			m_AvatarGo = false;
			m_PlayerDefeated  = false;
			m_PathToMainChest = null;
			m_PathToActivateObj = null;
			m_PathtoDoor = null;
			m_MsgBoxManager.hideAll();
			
			var nextRoomID:int = door.LinkRoom;
			//get the new room
			var room:Room = m_Realm.getRoom(String(nextRoomID));
			//destroy current room
			destroyRoom();
			
			while (m_BubbleTextList.length > 0)
				delete(m_BubbleTextList.pop())
			//load new room
			m_Realm.CurrentRoom = room;
			parseRoom(room.Data);
			killMonsters();//get rid of monsters that are already dead
			//in the chest room so load the chest
			if (nextRoomID == m_Realm.ChestRoomID)
				parseChest(m_RealmXML);
			
		}
		
		virtual public function reloadRoom():void {
			
			m_MapReady = false;
			m_MapRenderReady = false;
			m_AvatarGo = false;
			m_PlayerDefeated  = false;
			m_PathToMainChest = null;
			m_PathToActivateObj = null;
			m_PathtoDoor = null;
			m_MsgBoxManager.hideAll();
			//get the new room
			var room:Room = m_Realm.CurrentRoom;
			//destroy current room
			destroyRoom();
			
			while (m_BubbleTextList.length > 0)
				delete(m_BubbleTextList.pop())
			//load new room
			parseRoom(room.Data);
			killMonsters();//get rid of monsters that are already dead
			//in the chest room so load the chest
	
			if (m_Realm.CurrentRoomID == m_Realm.ChestRoomID)
				parseChest(m_RealmXML);
			
		}
		
		private function killMonsters():void {
			
			for each (var mob:MonsterCharacter in m_MonsterObjList)
			{
				//trace(mob.Id);
				if (m_Realm.CurrentRoom.getDeadMonster(mob.OwnerItemId))
				{
					mob.Visible = false;
					mob.die();
				}
			}
		}
		
		//parse all sprites file from the room.xml
		private function parseChest(xml:XML):void
		{
			//<chest file="/assets/realmz/fantasy/keepers/chest.png" xpos="3" ypos="3" walkable="false" overlap="false" facings="4" direction="SE" width="50" height="48" sfx="SFX" sfxtype="1">
			//	<SE_Default x_offset="-63" y_offset="0" rows="3" cols="1" frames="8" fps="10" animation="activate">0,1,2,3,4,5,6,7</SE_Default>
			//	<SW_Default x_offset="16" y_offset="-51" rows="1" cols="3" frames="8" fps="10" animation="activate">8,9,10,11,12,13,14,15</SW_Default>
			//	<NE_Default x_offset="15" y_offset="-51" rows="1" cols="3" frames="8" fps="10" animation="activate">8,9,10,11,12,13,14,15</NE_Default>
			//	<NW_Default x_offset="-63" y_offset="0" rows="3" cols="1" frames="8" fps="10" animation="activate">0,1,2,3,4,5,6,7</NW_Default>
			//	<property id="1" type="12" itemname="Chest 001" tooltip="Chest 001" coincost="1" iconfile=""/>
			//</chest>
			var list:XMLList = xml.dataset.chest
			for each (var elem:XML in list)
			{
				addChest(elem);
			}	
		}
		
		//add sprite file to the system
		private function addChest(xml:XML):void
		{
			//trace(xml);
			var Obj:ChestObject;
			Obj = new ChestObject(m_EditMode,this);
			Obj.loadFromXML(xml);
		}
		
		public function spawnRandomMonster():void {
			var url:String = Globals.RESOURCE_BASE + RealmConsts.ITEMS +"6&id=0";
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onRandomMonsterLoad);
			xmlLoader.load(new URLRequest(url));	
		}
		
		private function onRandomMonsterLoad(e:Event):void {
			var xml:XML = XML(e.target.data);
			var item:GameObject = null;
			
			item = loadEditorItem(xml);	
			
			var pnt:Point = m_Map.getEmptyTileFromCenter();
			m_Map.removeMonster(item);
			if (pnt != null)
				item.setPosition(pnt.x, pnt.y);
			else
				item.setPosition(3, 3);
			m_Map.placeMonster(item);
			sortLifeLayer();
		}
		
		//updates that need to be called before rendering the scene
		override public function updateBeforeRender():void 
		{
			if (!m_MapRenderReady) return;
			
			super.updateBeforeRender();
			for each (var bubble:BubbleText in m_BubbleTextList)
			{
				bubble.update();
			}
		}
		
		
		//Render the scene
		override public function render(layer:int):void 
		{
			if (!m_MapRenderReady) return;

			switch (layer)
			{
				case 0://Background
					super.render(layer);
					break;
				case 1://ground
					super.render(layer);
					break;
				case 2://life
					super.render(layer);
					break;
				case 3://light
					super.render(layer);
					if(m_BubbleTextList != null)
						for each (var bubble:BubbleText in m_BubbleTextList)
						{
							bubble.render();
						}
					break;
				case 4://Roof
					super.render(layer);
					break;
			}
		}
		
		//updates that need to be called after rendering the scene
		override public function updateAfterRender():void 
		{
			super.updateAfterRender();
		}

		
		public function saveNewItem():void
		{
				if (NewItem != null)
				{
					//TODO Buy Item;
					NewItem = null;
				}
		}
		
		
		private function GetBubbleText():BubbleText
		{
			var rtn:BubbleText = null;
			
			for each (var bt:BubbleText in m_BubbleTextList)
			{
				if (bt.Visible == false)
					return bt;
			}
			//make a new one of necessary	
			rtn = new BubbleText();
			m_BubbleTextList.push(rtn);
			return rtn;
			
		}	
			
			
		/* this isnt safe
		public function addToInventory(item:GameObject):void
		{
			var url:String;
			url = GameConstants.RESOURCE_BASE + GameConstants.ADDINVENT + "&id=" + item.ItemID + "&typ=" + item.ItemType;
			//trace(url);
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.load(new URLRequest(url));
		}
		
		public function removeFromInventory(item:GameObject):void
		{
			var url:String;
			url = GameConstants.RESOURCE_BASE + GameConstants.REMINVENT + "&id=" + item.ItemID + "&typ=" + item.ItemType;
			//trace(url);
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.load(new URLRequest(url));
		}
		*/
		protected function setPlayerEnergy(enrgy:int):void
		{
			AvatarStats(m_Stats).Energy = enrgy;
		}
		
		protected function addPlayerXp(xp:int, show:Boolean):void
		{
			AvatarStats(m_Stats).addExperince(xp);
			if (show)
				showPlayerGainXp(xp);
		}
		
		protected function addPlayerGold(gold:int, show:Boolean):void
		{
			AvatarStats(m_Stats).addGold(gold);
			if (show)
				showPlayerGainGold(gold);

		}

		protected function addPlayerBucks(bucks:int, show:Boolean):void
		{
			AvatarStats(m_Stats).addBucks(bucks);
			if (show)
				showPlayerGainBucks(bucks);

		}

		protected function addPlayerEnergy(enrgy:int, show:Boolean):void
		{
			AvatarStats(m_Stats).addEnergy(enrgy);
			if (show)
				showPlayerEnrgy(enrgy);

		}
		
		protected function removePlayerEnergy(enrgy:int, show:Boolean):void
		{
			AvatarStats(m_Stats).loseEnergy(enrgy);
			if (show)
				showPlayerEnrgy(enrgy);

		}
		
		protected function setPlayerMaxEnergy(enrgy:int, show:Boolean):void
		{
			AvatarStats(m_Stats).MaxEnergy = enrgy;
			//if (show)
			//	showPlayerMaxEnrgy();
			
		}
		
		protected function setPlayerFullEnergy(enrg:int, show:Boolean):void 
		{
			AvatarStats(m_Stats).Energy = enrg;
			
			if (show)
				showPlayerFullEnrgy();
		}
		
		protected function setPlayerLevel(level:int, show:Boolean):void
		{
			loadAvatarURL(Globals.RESOURCE_BASE + RealmConsts.AVATAR, true);
			AvatarStats(m_Stats).Level = level;
			if (show)
				showPlayerGainLevel(1);
		}
		
		
		protected function playerDefeat(show:Boolean):void
		{
			m_MsgBoxManager.showPlayerBuyPotion();

			if (show)
				showPlayerDefeatMessage();
		}
	
		
		public function showCapturedMonster(mob:String):void 
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 145);
			bText.showText("Captured a " + mob, 0x005CB3FF);
			var cpText:String = MsgConstants.CAPTURED_MONSTER
			cpText = cpText.replace("##mob##", mob).replace("##mob##", mob);
			m_MsgBoxManager.showMessageBox(cpText);
		}
	
		
		public function showPlayerFullEnrgy():void 
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 130);
			bText.showText("FULL POWER", 0x00736AFF);
		}
	
		
		public function showPlayerEnrgy(enrgy:int):void 
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 120);
			bText.showText("-" + enrgy + " POWER", 0x00736AFF);
		}
	
		public function showPlayerGainEnrgy(enrgy:int):void 
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 120);
			bText.showText("+" + enrgy + " POWER", 0x00736AFF);
		}
		
		public function showPlayerGainGold(gold:int):void
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 100);
			bText.showText("+" + gold + " GOLD", 0x00FDD017);

		}
		
		public function showPurchaseItem(item:GameObject):void
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(item.ScreenX-50, item.ScreenY - 100);
			bText.showText("-" + item.CoinCost + " GOLD", 0x00FDD017);

		}
		
		public function showPurchaseStruct():void
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(280, 220);
			bText.showText("-1 GOLD", 0x00FDD017);

		}
		
		public function showPlayerGainLevel(lvl:int):void
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 90);
			bText.showText("+" + lvl + " LEVEL", 0x005CB3FF);
			m_MsgBoxManager.showLevelupMsg();
		}

	
		public function showPlayerGainXp(xp:int):void
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 110);
			bText.showText("+" + xp + " XP", 0x00FFFFFF);
			
		}
	
		public function showItemGainXp(item:GameObject, xp:int):void
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(item.ScreenX-50, item.ScreenY - 85);
			bText.showText("+" + xp + " XP", 0x00FFFFFF);
			
		}
		
		public function showPlayerGainBucks(bucks:int):void
		{
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX - 50, m_Avatar.ScreenY - 130);
			if (bucks == 1)
				bText.showText("+" + bucks + " ALE BUCK", 0x00FDD017);
			else	
				bText.showText("+" + bucks + " ALE BUCKS", 0x00FDD017);
			
		}
		
		public function showPlayerDefeatMessage():void
		{
			m_PlayerDefeated = true;
			m_MsgBoxManager.showPlayerBuyPotion();
			
			var bText:BubbleText = GetBubbleText();
			bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 110);
			bText.showText("You have been defeated!", 0x005CB3FF);
			
			//bText = GetBubbleText();
			//bText.setPosition(m_Avatar.ScreenX-50, m_Avatar.ScreenY - 100);
			//bText.showText("Returning home.", 0x005CB3FF);
		}
		
		public function UpdateUIStats():void {
			AvatarStats(m_Stats).updateUI();
		}
		
		public function serverRequestStats():void {
			//update stats
			xmlStatsLoader = new URLLoader();
			xmlStatsLoader.addEventListener(Event.COMPLETE, onPlayerStatsXML);
			xmlStatsLoader.load(new URLRequest(Globals.RESOURCE_BASE + RealmConsts.PLAYER_STATS));
		}
		
		
		public function GetPlayerStats(e:TimerEvent):void {
			//update stats
			serverRequestStats();
		}
		
		private function onPlayerStatsXML(e:Event):void {
			//trace(e.target.data);
			xmlStatsLoader.removeEventListener(Event.COMPLETE, onPlayerStatsXML);
			xmlStatsLoader = null;
			if (e.target.data != "")
			{
				var xml:XML = XML(e.target.data);
				if (xml.header.status == "Success")
				{
					AvatarStats.loadFromStatsXML(xml);
					AvatarStats(m_Stats).updateUI();
				}
			}
		}
		
		protected function directionLookup(dir:String):int 
		{
			var rtn:int = 0;
			//trace(dir);
			switch(dir)
			{
				case "SE":
					rtn = 0;
					break;
				case "SW":
					rtn = 1;
					break;
				case "NW":
					rtn = 2;
					break;
				case "NE":
					rtn = 3;
					break;
			}
			return rtn;
		}
		
		public function toXML():String {
			
			var rtnXML:String;
			var StaticList:String = "";
			var SpriteList:String= "";
			var TrapList:String= "";
			var MonsterList:String= "";
			var WallDecalList:String= "";
			var SpriteDecalList:String= "";
			var ClickDecalList:String= "";
			var ClickList:String= "";
			
			
			var layerItem:GameObject;
			
			rtnXML = Map.toXML();

			for each (layerItem in m_LayerOneList)
			{//loop through all of the ground items and render them 
				switch (layerItem.ObjectType)
				{
					case 3:
						StaticList = StaticList + layerItem.toXML();
						break;
					case 4:
						SpriteList = SpriteList + layerItem.toXML();
						break;
					case 5:
						TrapList = TrapList + layerItem.toXML();
						break;
					case 6:
						MonsterList = MonsterList + layerItem.toXML();
						break;
					case 7:
						WallDecalList = WallDecalList + layerItem.toXML();
						break;
					case 8:
						SpriteDecalList = SpriteDecalList + layerItem.toXML();
						break;
					case 9:
						ClickDecalList = ClickDecalList + layerItem.toXML();
						break;
					case 10:
						ClickList = ClickList + layerItem.toXML();
						break;
				}
			

			}
			for each (layerItem in m_LayerTwoList)
			{//loop through all of the life items and render them
				switch (layerItem.ObjectType)
				{
					case 3:
						StaticList = StaticList + layerItem.toXML();
						break;
					case 4:
						SpriteList = SpriteList + layerItem.toXML();
						break;
					case 5:
						TrapList = TrapList + layerItem.toXML();
						break;
					case 6:
						MonsterList = MonsterList + layerItem.toXML();
						break;
					case 7:
						WallDecalList = WallDecalList + layerItem.toXML();
						break;
					case 8:
						SpriteDecalList = SpriteDecalList + layerItem.toXML();
						break;
					case 9:
						ClickDecalList = ClickDecalList + layerItem.toXML();
						break;
					case 10:
						ClickList = ClickList + layerItem.toXML();
						break;
				}
			}						
			
			if (StaticList != "")
			rtnXML = rtnXML + "<Statics>" + StaticList.toString() + "</Statics>";
			if (SpriteList != "")
			rtnXML = rtnXML + "<Sprites>" + SpriteList.toString() + "</Sprites>";
			if (TrapList != "")
			rtnXML = rtnXML + "<Traps>" + TrapList.toString() + "</Traps>";
			if (MonsterList != "")
			rtnXML = rtnXML + "<Monsters>" + MonsterList.toString() + "</Monsters>";
			if (WallDecalList != "")
			rtnXML = rtnXML + "<WallDecals>" + WallDecalList.toString() + "</WallDecals>";
			if (SpriteDecalList != "")
			rtnXML = rtnXML + "<SpriteDecals>" + SpriteDecalList.toString() + "</SpriteDecals>";
			if (ClickList != "" || ClickDecalList != "")
			rtnXML = rtnXML + "<Clickables>" + ClickList.toString() + ClickDecalList.toString() + "</Clickables>";
				
				
			rtnXML = rtnXML.replace("\r", "");
			rtnXML = rtnXML.replace("\n", "");
			
			return rtnXML;
		}
		
		
		
		
	}

}