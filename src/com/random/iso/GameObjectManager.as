package com.random.iso
{
	import com.random.iso.GameObject;
	import com.random.iso.GameStats;
	import com.random.iso.items.ActivateObject;
	import com.random.iso.items.DoorObject;
	import com.random.iso.items.SpriteObject;
	import com.random.iso.items.SpriteDecalObject;
	import com.random.iso.items.StaticObject;
	import com.random.iso.items.TrapObject;
	import com.random.iso.items.WallDecalObject;
	import com.random.iso.events.objectInteractionEvent;
	import com.random.iso.characters.avatar.LayerCharacter
	import com.random.iso.characters.monsters.MonsterCharacter;
	import com.random.iso.map.DragGrid;
	import com.random.iso.map.IsoMap;
	import com.random.iso.map.Realm;
	import com.random.iso.map.tile.Tile;
	import com.random.iso.map.tile.WayPoint;
	import com.random.iso.utils.IsoPoint;
	import com.random.iso.utils.IsoUtil;
	import com.random.iso.utils.astar.INode;
	import com.random.iso.utils.astar.Path;
	import com.random.iso.utils.astar.SearchResults;
	import com.random.iso.consts.*
	import com.random.iso.events.TileEvent
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.MouseEvent;
	import flash.xml.XMLNode;
	import flash.utils.setTimeout;
	import com.random.iso.ui.ToolTips;
	import org.flixel.*; //Allows you to refer to flixel objects in your code
	import com.random.game.UI.MsgBoxManager;
	/**
	 * Manages objects in the game. handles creating and deleting and tells them when to update and render
	 * ...
	 * @author Allen Halsted
	 */
	public class GameObjectManager
	{
		
		protected var m_MasterObjList:Array = []; //master list of all objects currently in the game
		protected var m_MobileObjList:Array = []; //lost of all mobile objects
		protected var m_MonsterObjList:Array = []; //lost of all mobile objects
		protected var m_LayerOneList:Array = []; //list of all items to be drawn on the ground under the players feet
		protected var m_LayerTwoList:Array = new Array(); //list of all items to be drawn and stored with the player
		protected var m_LayerThreeList:Array = []; //List of effects and lights to be drawn on top of the player
		protected var m_SpriteList:Array = []; //list of objects in the game that need to be animated
		protected var m_Avatar:LayerCharacter = null;//pointer the player characters
		protected var m_Map:IsoMap; //The isometric map object
		protected var m_AvatarReady:Boolean = false; //noted if the player is ready to be used
		protected var m_RoomParsed:Boolean = false; //not if the map is ready to be used
		protected var m_MapReady:Boolean = false; //not if the map is ready to be used
		protected var m_MapRenderReady:Boolean = false; //not if the map is ready to be used
		protected var m_EditMode:Boolean = false; //running in map edit more
		protected var m_CurrentSelected:GameObject; //pointer ot the currently selected gameobject
		protected var m_PreviousSelected:GameObject;//pointer ot the previously selected gameobject
		protected var m_ItemBeingDragged:GameObject = null; //pointer to the gameobject that is being dragged
		protected var m_DragGrid:DragGrid; //the placement grid that appears around an object that is being dragged. 
		protected var m_IsoUtil:IsoUtil = new IsoUtil(); 
		protected var m_CurrentRoom:XML;//hold the old XML so can undo all changes at once
		protected var m_Loading:Boolean = false;
		protected var m_NewItem:GameObject = null;//pointer to the gameobject that is being purchased
		protected var m_Stats:GameStats;
		protected var m_NewPathTile:Tile = null;
		private var m_allreadywatch:int = 0;
		private var m_MonsterCount:int = 0;
		protected var m_GameMode:int = 0;
		protected var m_AvatarGo:Boolean = false;
		public function GameObjectManager()
		{
			init();
		}
		
		public function set GameMode(value:int):void { m_GameMode = value; }
		public function set Avatar(value:LayerCharacter):void  { m_Avatar = value; }
		public function get Avatar():LayerCharacter  { return m_Avatar; }
		public function get EditMode():Boolean { return m_EditMode; }
		public function set EditMode(value:Boolean):void { 
			
			m_EditMode = value; 
			for each (var masterlayer:GameObject in m_MasterObjList)
			{
				masterlayer.EditMode = m_EditMode;
			}	
			
			if (m_Map)
			{
				if (m_EditMode)
					m_Map.showGrid()
				else
					m_Map.hideGrid();
			}
		}
		 
		public function get GameMode():int { return m_GameMode; }
		public function get Map():IsoMap { return m_Map; }
		public function get CurrentSelected():GameObject { return m_CurrentSelected; }
		public function get AvatartReady():Boolean { return m_AvatarReady; };
		public function get LayerOneList():Array { return m_LayerOneList; }
		public function get LayerTwoList():Array { return m_LayerTwoList; }
		public function get LayerThreeList():Array { return m_LayerThreeList; }
		public function get MobileObjectList():Array { return m_MobileObjList; }
		public function get MasterObjectList():Array { return m_MasterObjList; }
		public function get SpriteObjectList():Array { return m_SpriteList; }
		public function get ItemBeingDragged():GameObject { return m_ItemBeingDragged; }
		public function get NewItem():GameObject { return m_NewItem; }
		public function set NewItem(value:GameObject):void { m_NewItem = value; }
		public function get Stats():GameStats { return m_Stats; }
		public function set Stats(value:GameStats):void { m_Stats = value; }
		 
		 	
		
		virtual public function onClick(mousex:int,mousey:int):void { }
        
		//load the room for an XML file
		//this will be the start point
		virtual public function parseRoom(xml:XML):void
		{
			//trace(xml);
			m_Loading = true;
			m_CurrentRoom = xml;
			loadMap(xml);
			parseStatics(xml);
			parseWallDecals(xml);
			parseSpriteDecals(xml);
			parseMonsters(xml);
			//parseTraps(xml);
			parseActivate(xml);
			parseSprite(xml);
			parseDoor(xml);
			m_allreadywatch = 0;
			allReady();
			
		}
		
		//reset the room to its load state
		public function destroyRoom():void
		{
			m_CurrentSelected = null;
			m_ItemBeingDragged = null;
			m_PreviousSelected = null;
			
			//loop throuhg all objects and remove them
			for (var i:int = 0; i < m_MasterObjList.length;++i) {
					removeItem(m_MasterObjList[i], true);
					GameObject(m_MasterObjList[i]).cleanUp();
			}
			while (m_MasterObjList.length > 0)
				delete(m_MasterObjList.pop());
			//delete all the tiles and destory the grid
			m_Map.cleanUp();
			
			m_MasterObjList = []; //master list of all objects currently in the game
			m_MonsterObjList = [];
			m_MobileObjList = []; //lost of all mobile objects
			m_LayerOneList = []; //list of all items to be drawn on the ground under the players feet
			m_LayerTwoList = new Array(); //list of all items to be drawn and stored with the player
			m_LayerThreeList = []; //List of effects and lights to be drawn on top of the player
			m_SpriteList = []; //list of objects in the game that need to be animated
			m_MapReady = false;
			m_NewItem = null;
			ToolTips.hide();
			//clear all the images out of memory
			//FlxG.clearCache();
			
		}
		
		virtual public function cleanUp():void {
			
			destroyRoom();
			m_Avatar = null;
			m_Map = null;
			
		}
		
		public function cancelNewItem():void
		{
			if (m_NewItem != null)
				removeItem(m_NewItem, false);
			m_NewItem = null;
			m_DragGrid.Enabled = false;
			m_ItemBeingDragged = null;
		}
		//parse all  static files from the room.xml
		private function parseWallDecals(xml:XML):void
		{
			//<walldecal id="9" layer="1" file="assets/statics/painting1_a.png" xpos="0" ypos="7" x_offset="-60" y_offset="-150" rows="1" cols="1" width="68" height="151" facings="2" walkable="true" overlap="true" />
			var list:XMLList = xml.objects.WallDecals.walldecal 
			for each (var elem:XML in list)
			{
				addWallDecal(elem);
			}
		}

		//parse all  static files from the room.xml
		private function parseSpriteDecals(xml:XML):void
		{
			//<spritedecal id="22" layer="1" file="assets/sprites/candle.png" xpos="0" ypos="0" x_offset="-60" y_offset="-140" rows="1" cols="1" framecount="9" width="32" height="56" facings="2" walkable="true" overlap="true" direction="SE" />
			var list:XMLList = xml.objects.SpriteDecals.spritedecal 
			for each (var elem:XML in list)
			{
				addSpriteDecal(elem);
			}
		}
		
		//parse all  static files from the room.xml
		private function parseActivate(xml:XML):void
		{
			
			//<spritedecal id="22" layer="1" file="assets/sprites/candle.png" xpos="0" ypos="0" x_offset="-60" y_offset="-140" rows="1" cols="1" framecount="9" width="32" height="56" facings="2" walkable="true" overlap="true" direction="SE" />
			var list:XMLList = xml.objects.Clickables.clickable 
			trace(list);
			for each (var elem:XML in list)
			{
				addActivate(elem);
			}
		}
		
		//Add a new static file to the system
		public function addWallDecal(xml:XML):WallDecalObject
		{
			var Obj:WallDecalObject;
			Obj = new WallDecalObject(m_EditMode,this);
			Obj.loadFromXML(xml);
		
			return Obj;
		}
		
		//Add a new static file to the system
		public function addSpriteDecal(xml:XML):SpriteDecalObject
		{
			var Obj:SpriteDecalObject;
			Obj = new SpriteDecalObject(m_EditMode,this);
			Obj.loadFromXML(xml);
		
			return Obj;
		}
		
		//Add a new static file to the system
		public function addActivate(xml:XML):ActivateObject
		{
			var Obj:ActivateObject;
			Obj = new ActivateObject(m_EditMode,this);
			Obj.loadFromXML(xml);
		
			return Obj;
		}
		
		//parse all  static files from the room.xml
		private function parseStatics(xml:XML):void
		{
			//<staticobj layer="2" file="assets/bed_blue.png" xpos="0" ypos="0" x_offset="-125" y_offset="-45" rows="4" cols="3" walkable="false" overlap="false" />
			var list:XMLList = xml.objects.Statics.staticobj 
			for each (var elem:XML in list)
			{
				addStatic(elem);
			}
		}

		//Add a new static file to the system
		public function addStatic(xml:XML):StaticObject
		{
			var Obj:StaticObject;
			Obj = new StaticObject(m_EditMode,this);
			Obj.loadFromXML(xml);
		
			return Obj;
		}
	
			//parse all  static files from the room.xml
		private function parseDoor(xml:XML):void
		{
			
			// <doorobj file="/assets/realmz/fantasy/statics/door_01.png" itemid="136" xpos="0" ypos="6" layer="1" walkable="false" overlap="false" facings="2" direction="SW" link="2" width="83" height="172">
			
			var list:XMLList = xml.objects.Doors.doorobj 
			for each (var elem:XML in list)
			{
				addDoor(elem);
			}
		}
		
		//Add a new static file to the system
		public function addDoor(xml:XML):DoorObject
		{
			var Obj:DoorObject;
			Obj = new DoorObject(m_EditMode,this);
			Obj.loadFromXML(xml);
		
			return Obj;
		}
	
		
		//parse all monsters files from the room.xml
		private function parseMonsters(xml:XML):void {
			//<monster file="data/spider.xml" xpos="8" ypos="8" rows="5" cols="5" moveable="true" />
			var list:XMLList = xml.objects.Monsters.monster; 
			for each (var elem:XML in list)
			{
				addMonster(elem);
			}
		}
		//add the new monster ot the game
		public function addMonster(xml:XML):MonsterCharacter {
			//create monster
			var mob:MonsterCharacter = new MonsterCharacter(m_EditMode, this)
			mob.loadFromXML(xml);
			m_MonsterObjList.push(mob);
			return mob;
		}
		
		//passe all of the trap files from room.xml
		private function parseTraps(xml:XML):void {
			//<trap file="assets/traps/gastrap.png" xpos="8" ypos="10" rows="5"  cols="5" x_offset="76" y_offset="88" />
			var list:XMLList = xml.objects.Traps.trap;
			for each (var elem:XML in list)
			{
				addTrap(elem);
			}
		}
		//add the new trap to the game
		public function addTrap(xml:XML):TrapObject {
			//create trap
			var trap:TrapObject = new TrapObject(m_EditMode,this);
			trap.loadFromXML(xml)
						
			return trap;
		}

		//get an item xml from the UI to load into the editor
		public function loadEditorItem(xml:XML ):GameObject
		{
			var file:String;
			var rtnObj:GameObject = null;
			var type:int = 0;
			var list:XMLList;
			var elem:XML;
			type = int(xml.dataset.Statics.staticobj.property.@type);
			if (type == 0) type = int(xml.dataset.Sprites.spriteobj.property.@type);
			if (type == 0) type = int(xml.dataset.Monsters.monster.property.@type);
			if (type == 0) type = int(xml.dataset.WallDecals.walldecal.property.@type);
			if (type == 0) type = int(xml.dataset.SpriteDecals.spritedecal.property.@type);
			if (type == 0) type = int(xml.dataset.ClickDecals.clickdecal.property.@type);
			if (type == 0) type = int(xml.dataset.Clickables.clickable.property.@type);
			if (type == 0) type = int(xml.dataset.Traps.trap.property.@type);
			if (type == 0) type = int(xml.dataset.Floor.floor.property.@type);
			if (type == 0) type = int(xml.dataset.Walls.rightwall.property.@type);
			if (type == 0) type = int(xml.dataset.Walls.leftwall.property.@type);
			switch (type)
			{
				case 3:
					list = xml.dataset.Statics.staticobj 
					for each (elem in list)
					{
						rtnObj = addStatic(elem);
					}
					break;
				case 4:
					list = xml.dataset.Sprites.spriteobj 
					for each (elem in list)
					{
						rtnObj = addSprite(elem);
					}
					break;
				case 6:
					list = xml.dataset.Monsters.monster 
					for each (elem in list)
					{
						rtnObj = addMonster(elem);
					}
					break;
				case 7:
					
					list = xml.dataset.WallDecals.walldecal 
					for each (elem in list)
					{
						rtnObj = addWallDecal(elem);
					}
					break;
					
				case 8:
					list = xml.dataset.SpriteDecals.spritedecal 
					for each (elem in list)
					{
						rtnObj = addSpriteDecal(elem);
					}
					break;	
				case 9:
					list = xml.dataset.ClickDecals.clickdecals
					for each (elem in list)
					{
						rtnObj = addActivate(elem);
					}
					break;

				case 10:
					list = xml.dataset.Clickables.clickable 
					for each (elem in list)
					{
						rtnObj = addActivate(elem);
					}
					break;
				case 5:
					list = xml.dataset.Traps.trap
					for each (elem in list)
					{
						rtnObj = addTrap(elem);
					}
					break;
				case 2:
					m_Map.loadNewFloor(XML(xml.dataset.Floor));
					break;
				case 0:
				case 1:
					m_Map.loadNewWall(XML(xml.dataset.Walls));
					break;
			}
			//after the new object is loaded return a pointer to it.
			return rtnObj;
		}
	
		//rotate a mulitfacing item through it various directions clockwise
		virtual public function rotateItem(item:GameObject):void {
			
			var dir:String = item.Dir;
			if (item.Layer == 1) return;
			
			if (item.FacingCount == 4)
			{
				switch (dir)
				{
					case IsoConstants.DIR_NE: //Facing North East 
						item.setDir(IsoConstants.DIR_SE); //change to South East
					break;
					case IsoConstants.DIR_NW://Facing North West
						item.setDir(IsoConstants.DIR_NE); //change to North East
					break;
					case IsoConstants.DIR_SE://facing South East
						item.setDir(IsoConstants.DIR_SW); //change to South West
					break;
					case IsoConstants.DIR_SW://facing South West 
						item.setDir(IsoConstants.DIR_NW);//change to North East
					break;
				}
			}else 
			if (item.FacingCount == 2)
			{
				switch (dir)
				{
					case IsoConstants.DIR_SE://facing South East
						item.setDir(IsoConstants.DIR_SW); //change to South West
					break;
					case IsoConstants.DIR_SW://facing South West 
						item.setDir(IsoConstants.DIR_SE); //change to South East
					break;
				}
			}
			
			moveItem(item);
			//this does not work switch back!
			//m_Map.removeItem(item);
			//if (!m_Map.placementTest(item))
			//{
			//	item.setDir(dir);
			//	MsgBoxManager.staticShowMessage(MsgConstants.ROTATE_HERE);
			//}else
			//	m_Map.placeItem(item);
			
		}
		
		//remove the item from the world after it has been sold or picked up
		public function removeItem(item:GameObject, ignoreMaster:Boolean = false):void {
			
			if (item == null) return;
			//remove the item from the map
			m_Map.removeItem(item);

			var i:int;
			//remove the item from its render layer
			
			switch (item.Layer)
			{
				case 0:
				case 1:
						for (i = 0; i < m_LayerOneList.length;++i) {
							if (m_LayerOneList[i] == item) {
								m_LayerOneList.splice(i, 1);
								break;
							}
						}
					break;
				case 2:
						for (i = 0; i < m_LayerTwoList.length;++i) {
							if (m_LayerTwoList[i] == item) {
								m_LayerTwoList.splice(i, 1);
								break;
							}
						}
					//should resort just incase
					sortLifeLayer();
					break;
				case 3:
						for (i = 0; i < m_LayerThreeList.length;++i) {
							if (m_LayerThreeList[i] == item) {
								m_LayerThreeList.splice(i, 1);
								break;
							}
						}
					break;
			}
			
			//remove the item from the mobile layer
			for (i = 0; i < m_MobileObjList.length;++i) {
				if (m_MobileObjList[i] == item) {
					m_MobileObjList.splice(i, 1);
					break;
				}
			}
			
			//remove the item from the sprite list
			for (i = 0; i < m_SpriteList.length;++i) {
				if (m_SpriteList[i] == item) {
					m_SpriteList.splice(i, 1);
					break;
				}
			}
			
			
			if (!ignoreMaster)
			{//do this only if the item is really being deleted
				//remove the item from the master layer
				for (i = 0; i < m_MasterObjList.length;++i) {
					if (m_MasterObjList[i] == item) {
						m_MasterObjList.splice(i, 1);
						break;
					}
				}
			}

		}
		//take the item out of the game world and attach it to the mouse
		public function moveItem(item:GameObject):void {
			//remove the item from the map
			m_Map.removeItem(item);
			m_ItemBeingDragged = item;
			if (m_CurrentSelected)
				m_CurrentSelected.onMouseOut();
			m_DragGrid.createDragGrid(item);
			
			//make my first move
			m_DragGrid.moveItem(m_ItemBeingDragged);
			
		}
		
		
		//take the item out of the game world and attach it to the mouse
		public function cancelMoveItem():void {
			if (m_ItemBeingDragged != null && m_EditMode)
			{
				m_ItemBeingDragged.setPosition(m_DragGrid.StartX, m_DragGrid.StartY);
				if (m_ItemBeingDragged is StaticObject)
						m_Map.placeItem(m_ItemBeingDragged);
					else if (m_ItemBeingDragged is SpriteObject)
						m_Map.placeItem(m_ItemBeingDragged);
					else
						m_Map.placeMonster(m_ItemBeingDragged);
				
				m_DragGrid.Enabled = false;
				m_ItemBeingDragged = null;
				sortLifeLayer();
			}
		}
		
		
		//parse all sprites file from the room.xml
		private function parseSprite(xml:XML):void
		{
			//trace(xml);
			//<sprite id="23" layer="2" file="assets/sprites/grim.png" xpos="0" ypos="0" x_offset="-60" y_offset="-140" rows="1" framecount="9" cols="1" width="48" height="77" facings="2" walkable="false" overlap="false" direction="SE" />
			var list:XMLList = xml.objects.Sprites.spriteobj 
			for each (var elem:XML in list)
			{
				addSprite(elem);
			}	
		}

		//add sprite file to the system
		private function addSprite(xml:XML):SpriteObject
		{
			//trace(xml);
			var Obj:SpriteObject;
			Obj = new SpriteObject(m_EditMode,this);
			Obj.loadFromXML(xml);
		
			return Obj;
		}
		
		virtual protected function init():void {
			m_Map = new IsoMap();
		}
		
		public function getMonsterCount():int {
			var rtn:int = 0;
			for (var i:int = 0; i < m_MasterObjList.length;++i) {
				if (m_MasterObjList[i] is MonsterCharacter)
					rtn++;
			}
			return rtn;
		}
		
		public function getTrapCount():int {
			var rtn:int = 0;
			for (var i:int = 0; i < m_MasterObjList.length;++i) {
				if (m_MasterObjList[i] is TrapObject)
					rtn++;
			}
			return rtn;
		}
		
		//create and load the map 
		 private function loadMap(xml:XML):void
		{
			
			m_Map.addEventListener(IsoMap.DATA_READY, onMapDataReady);
			m_Map.addEventListener(IsoMap.RENDER_READY, onMapRenderReady);
			m_Map.processMapXML(xml);
			if (m_EditMode)
			{//in edit mode want to show the grid
				m_Map.showGrid()
				m_DragGrid = new DragGrid(m_Map);
			}
			else
				m_Map.hideGrid();

			//m_Map.showGrid();	
		}
		
		
		public function loadAvatarURL(url:String, xmlOnly:Boolean):void {
			if (m_Avatar == null && !xmlOnly)
			{
				m_Avatar = new LayerCharacter();
				m_Avatar.Visible = false;
				m_Avatar.addEventListener(LayerCharacter.READY, onAvatarReady);			
			}
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onLoadAvatarXML);
			xmlLoader.load(new URLRequest(url));	
		}
		
		private function onLoadAvatarXML(e:Event):void {
			var xml:XML = new XML(e.target.data);
			
			if (xml.header.status == "Success") {
				GameConstants.AVATAR_XML = e.target.data;
				m_Stats.loadFromXML(xml);
				if (m_Avatar != null)
				{
					m_Avatar.loadFromXML(xml)
				}
			}
		}	
		
		public function loadAvatarXML(xmlOnly:Boolean):void {
			
			if (m_Avatar == null && !xmlOnly)
			{
				m_Avatar = new LayerCharacter();
				m_Avatar.addEventListener(LayerCharacter.READY, onAvatarReady);			
			}
			
			var xml:XML = new XML(GameConstants.AVATAR_XML);
			
			if (GameConstants.STATS_XML != "")
				m_Stats.setXMLString();
			else
				m_Stats.loadFromXML(xml);
			
			if (m_Avatar != null)
			{
				m_Avatar.loadFromXML(xml)
				m_Avatar.Visible = false;
			}
		}
		
		private function allReady():void {
			if (m_AvatarReady && m_MapReady)
			{
				if (m_allreadywatch < 30)//about 3 seconds
				//loop throuhg all objects
				for (var i:int = 0; i < m_MasterObjList.length;++i) {
					if (!GameObject(m_MasterObjList[i]).Loaded)
					{
						setTimeout(allReady, 100);
						m_allreadywatch++;
						return;
					}
				}
				setupAvatar();
				sortWallLayer();
			}
			else
				setTimeout(allReady, 100);
		}
		private function onAvatarReady(e:Event):void 
		{
			m_Avatar.removeEventListener(LayerCharacter.READY, onAvatarReady);	
			m_AvatarReady = true;
		}
		
		virtual public function setupAvatar():void {
			
			m_Avatar.setDir(IsoConstants.DIR_SE);
			m_Avatar.doAction(ActionConstants.IDLE);
			m_Avatar.setPosition(3, 3); 
			m_AvatarGo = true;
		}
		
		//map is ready event
		public function onMapDataReady(e:Event):void {
			m_Map.removeEventListener(IsoMap.DATA_READY, onMapDataReady);
			m_MapReady = true;
			
		}
		//map is ready event
		public function onMapRenderReady(e:Event):void {
			m_Map.removeEventListener(IsoMap.RENDER_READY, onMapRenderReady);
			m_MapRenderReady = true;
			
		}
		
		//updates that need to be called before rendering the scene
		virtual public function updateBeforeRender():void 
		{
			if (!m_MapRenderReady) return; 
			m_Map.update();
		
			for each (var sprite:GameObject in m_SpriteList)
			{
				sprite.update();
			}	
			
			for each (var mob:MobileObject in m_MobileObjList)
			{
				mob.update();
			}
		}
		
		
		//Render the scene
		virtual public function render(layer:int):void 
		{
			var layerItem:GameObject;
			if (!m_MapRenderReady) return;
			
			switch (layer)
			{
				case 0://Background
					m_Map.render();
					break;
				case 1://ground
					if(m_EditMode)	m_DragGrid.render();
					//m_map.renderGrid();
					for each (layerItem in m_LayerOneList)
					{//loop through all of the ground items and render them 
						layerItem.render();
					}

					break;
				case 2://life
					if (m_ItemBeingDragged != null && m_ItemBeingDragged.Layer <= 1)
						break; //dont render layer 2 when layer is is being dragged
					for each (layerItem in m_LayerTwoList)
					{//loop through all of the life items and render them
						layerItem.render();
					}						
					break;
				case 3://light
					//if (m_ItemBeingDragged) m_ItemBeingDragged.render();
					for each (layerItem in m_LayerThreeList)
					{
						layerItem.render();
					}	
								
					break;
				case 4://Roof
					
					break;
			}
		}
		
		//updates that need to be called after rendering the scene
		virtual public function updateAfterRender():void 
		{
			if (!m_MapReady) return;
				moveMobile();
		}
		
		//track the mouse around the game screen
		virtual public function onMouseMove(mousex:int, mousey:int):void {
			
			m_PreviousSelected = m_CurrentSelected;
			m_CurrentSelected = null;
			
			for each (var masterlayer:GameObject in m_MasterObjList)
			{
				if (masterlayer.getMouseOver(mousex, mousey)) 
				{//only find the first one
					
					//outside of edit mode only care about a few object types
					if (masterlayer is DoorObject)
					{
						m_CurrentSelected = masterlayer; 
						break;
					}else
					if (masterlayer is MonsterCharacter)
					{
						if (MonsterCharacter(masterlayer).Status == StatusConstants.ALIVE)
						{	
							m_CurrentSelected = masterlayer; 
							break;
						}
					}else
					if (masterlayer is ActivateObject)
					{
						m_CurrentSelected = masterlayer; 
						break;
					}
				}
			}	
			
			if (m_CurrentSelected != m_PreviousSelected)
			{ //if there was a previous one then clear it
				if (m_PreviousSelected != null)
					m_PreviousSelected.setMouseOut();
			}
		}
		
		
		//Recieve mouse Move events from the engine
		 public function onMouseMoveEditMode(mousex:int, mousey:int):void {
			
			m_PreviousSelected = m_CurrentSelected;
			m_CurrentSelected = null;
			
			if (m_ItemBeingDragged != null)
			{//if dragging a item then only worry about at item. 
			    var t:Tile =  m_Map.getTileFromScreenCoordinates(mousex, mousey);
				
				if (t)
				{
					if (m_ItemBeingDragged.xPos != t.Col || m_ItemBeingDragged.yPos != t.Row)
					{//actually moved to a new tile
						m_ItemBeingDragged.setPosition(t.Col, t.Row);
						m_DragGrid.moveItem(m_ItemBeingDragged);
						
						if (m_ItemBeingDragged.Layer == 2) //only sort when have to
							sortLifeLayer();
					}
				}
				return;
			}
			
			for each (var masterlayer:GameObject in m_MasterObjList)
			{
				if (masterlayer.getMouseOver(mousex, mousey)) 
				{//only find the first one
					m_CurrentSelected = masterlayer; 
					break;
				}
			}	
			
			if (m_CurrentSelected != m_PreviousSelected)
			{ //if there was a previous one then clear it
				if (m_PreviousSelected != null)
					m_PreviousSelected.setMouseOut();
			}
			
			
		}
		
		
		//user clicked on a tile not in edit mode
		protected function onTileClicked(tile:Tile):void {
		    
			//m_Avatar.faceTarget(tile.Col, tile.Row);
			
			if (m_AvatarReady && !m_EditMode)
			{
				if (m_Avatar.Moving)
				{//already moving so put the path in queque
					m_NewPathTile = tile;
				}else
				{
					var path:Array = getAStarPath(m_Avatar, tile);
					if (path) walkMobile(m_Avatar, path);
				}	
			}
			
		}
		
		
		
		/* Pathfinding Stuff */
		public function getAStarPath(mob:MobileObject, tile:Tile):Array {
			
			var startNode:INode = m_Map.getTile(mob.xPos, mob.yPos);
			var goalNode:INode = tile;
			var path_arr:Array = [];
			var tiles:Array = [];
			var results:SearchResults = m_Map.A_Star.search(startNode, goalNode);
			if (results.getIsSuccess()) {
					
				var path:Path = results.getPath();
				//get the actual tiles for the path that AStar returned	
				for (var i:int = 0; i < path.getNodes().length;++i) {
					var n:INode = path.getNodes()[i];
					path_arr.push(n.getCol());
					path_arr.push(n.getRow());
				}
			
				for (var j:int = 0; j < path_arr.length; j += 2) {
					var col:int = path_arr[j];
					var row:int = path_arr[j + 1];
					var tile:Tile = m_Map.getTile(col, row);
					tiles.push(tile);
				}
			}
			
			return tiles ;
		}
		
		public function walkMobile(mob:MobileObject, tiles:Array):void {
			
			var wpIndex:int = 0;
			var wayPoints:Array = [];
			var time:Number = getTimer();

			for (var i:int = 0; i < tiles.length;++i) {
				var tile:Tile = tiles[i];
				var dis:Number;
				if (i != 0) {
					dis = m_Map.getDistance(tile, tiles[i - 1]);
					time += dis / mob.WalkSpeed;
				}
					
				var wp:WayPoint = new WayPoint();
				wp.Time = Math.round(time);
				wp.LinkTile = tile;
				
				if (getTimer() > wp.Time) {
					wpIndex = i;
				}
					
				wayPoints.push(wp);
			}
				
			mob.walk(wayPoints);
			mob.WayPointIndex = wpIndex;
		}
		
		
	
		
		protected function onStoppedOnTile(e:TileEvent):void {
			var mapToLoad:String = e.eventParameter;
			
			//_destination = mapToLoad;
			//dispatchEvent(new Event(TELEPORT));
		}
		
		
		protected function moveMobile():void{
			
			for each (var mob:MobileObject in m_MobileObjList) {
				if (mob.CurrentAction == ActionConstants.WALK) {
					stepMobile(mob);
				}
			}
		}
		
		protected function stepMobile(mob:MobileObject):void{
			var time:Number = getTimer();
			var wp:WayPoint;
			var ind:int = mob.WayPointIndex;
			
			//is it time for the next way point?
			if (ind < mob.WayPoints.length - 1) {
				wp = mob.WayPoints[ind + 1];
				if (time > wp.Time) {
					
					//switch to the next way point head for it
					ind = ind +1;
					wp = mob.WayPoints[ind];
					mob.WayPointIndex = ind;
					
					mob.setPosition(wp.LinkTile.Col, wp.LinkTile.Row);
					sortLifeLayer(); 
					
					if (mob == m_Avatar)//see if the tile the player is on has an event
					{
						//see if the player needs to change direction
						if (m_NewPathTile != null)
						{//there is a new direction in queueu
							//make a backup
							var tmp:Tile =  m_NewPathTile;
							m_NewPathTile = null; //clear this before we start just incase
							m_Avatar.onStopMoving();//stop the character from moving
							onTileClicked(tmp);//head to the next tile
							return;//done here for now
						}
						
						if (checkForTileEvents(wp.LinkTile)) return;
					}
					
					//sortLifeLayer();
				}
			}
			
			//next way point to move too
			wp = mob.WayPoints[ind];
			
			var x:Number;
			var y:Number = 0;
			var z:Number;
			
			//position in isometric space
			x = m_Map.TileWidth * wp.LinkTile.Col;
			z = m_Map.TileHeight * wp.LinkTile.Row;
			
			var elapsed:Number = getTimer() - wp.Time;

			if ((ind == mob.WayPoints.length - 1) || !(mob.WayPoints[ind + 1]).LinkTile.Walkable )   {
				//at the end of the list or next tile is not walkable or next tile has a mob in it
				mob.onStopMoving();
				if (mob == m_Avatar)//see if the tile the player is on has an event
					checkForAvatarOnStopEvent(mob);
				else
					checkForOnStopEvent(mob);
				return;	
			}else {
			//keep moving
				x += elapsed * mob.WalkSpeed *mob.CosAngle;
				z += elapsed * mob.WalkSpeed * mob.SinAngle;
			}			
			
			var coord:IsoPoint = m_IsoUtil.mapToScreen(x, y, -z);
			mob.ScreenX = coord.X - m_Map.ScreenXOffset;
			mob.ScreenY = coord.Y - m_Map.ScreenYOffset;
			
		}
		//see if there is already a mob on the tile I am about ot go to
		private function checkMobileCollision(mobile:MobileObject, tile:Tile):Boolean {

			for each (var mob:MobileObject in m_MobileObjList)
			{//see where all of the mobs are
				if ((mob.OwnerItemId != mobile.OwnerItemId) && mob.isLoaded() && (mob.Status != StatusConstants.DEAD))
				{
					if (tile == m_Map.getTile(mob.xPos, mob.yPos)) //there is a mob on this tile
						return true;
				}
			}	
			return false;
		}
		
		
		
		//stepped on a tile see if something needs to happen
		virtual protected function checkForTileEvents(tile:Tile):Boolean 
		{
				return false;
		}
		
		//this is where I was going or as close and I am going to get
		virtual protected function checkForOnStopEvent(mob:MobileObject):void
		{
			sortLifeLayer(); 
		}
	
		//this is where I was going or as close and I am going to get
		virtual protected function checkForAvatarOnStopEvent(mob:MobileObject):void{
			
			//look for events on the tile
			var tile:Tile = m_Map.getTile(mob.xPos, mob.yPos);
			for (var i:int = 0; i < tile.ItemsList.length;++i) {
				var itm:GameObject = tile.ItemsList[i];
				if (itm.onStopEvent != null) {
					var evt:TileEvent = new TileEvent(TileEvent.STOPPED_ON_TILE, tile);
					evt.eventParameter = itm.onStopEvent;
					//dispatchEvent(evt);
				}
			}
			
		}
		
		
		public function closeToObject(obj:GameObject):Boolean {
			var startX:int = m_Avatar.xPos;
			var startY:int = m_Avatar.yPos;
			var endX:int = obj.xPos;
			var endY:int = obj.yPos;
			var rtn:Boolean = false;
			
			if (Math.abs(startX - endX) < 3)
				if (Math.abs(startY - endY) < 3)
					rtn = true;
			
			return rtn;
		}
		
		/**
		 * Sorts all sortable items.
		 */
		 public function sortLifeLayer():void {	
			var list:Array = m_LayerTwoList.slice(0);
			
			m_LayerTwoList = [];
			
			for (var i:int = 0; i < list.length;++i) {
				var nsi:ISortable = list[i];
				
				var added:Boolean = false;
				for (var j:int = 0; j < m_LayerTwoList.length;++j ) {
					var si:ISortable = m_LayerTwoList[j];
					if (nsi.yPos <= si.yPos + si.Rows - 1 && nsi.xPos <= si.xPos + si.Cols - 1) {
					
						m_LayerTwoList.splice(j, 0, nsi);
						added = true;
						break;
					}
				}
				if (!added) {
					m_LayerTwoList.push(nsi);
				}
			}
			
			postSortUpdate();
		}
		
		 public function sortWallLayer():void {	
			var list:Array = m_LayerOneList.slice(0);
			
			m_LayerOneList = [];
			
			for (var i:int = 0; i < list.length;++i) {
				var nsi:ISortable = list[i];
				
				var added:Boolean = false;
				for (var j:int = 0; j < m_LayerOneList.length;++j ) {
					var si:ISortable = m_LayerOneList[j];
					if (nsi.yPos <= si.yPos + si.Rows - 1 && nsi.xPos <= si.xPos + si.Cols - 1) {
					
						m_LayerOneList.splice(j, 0, nsi);
						added = true;
						break;
					}
				}
				if (!added) {
					m_LayerOneList.push(nsi);
				}
			}
		}
		
		
		virtual public function postSortUpdate():void 
		{//keep keepers behind the chests
			return;
		}
	}	

}