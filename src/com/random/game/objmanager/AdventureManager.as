package  com.random.game.objmanager
{
		import com.random.iso.items.DoorObject;
		import flash.geom.Point;
		import com.random.game.MyRealmObjManager;
		import com.random.game.combat.CombatController;
		import com.random.iso.map.tile.Tile;
		import flash.display.Loader;
		import flash.display.LoaderInfo;
		import flash.net.URLRequest;
		import flash.net.URLLoader;
		import flash.events.Event;
		import com.random.iso.GameObject;
		import com.random.game.items.ChestObject;
		import com.random.iso.MobileObject;
		import com.random.iso.items.StaticObject;
		import com.random.iso.items.SpriteObject;
		import com.random.iso.items.ActivateObject;
		import com.random.iso.items.TrapObject;
		import com.random.iso.consts.GameConstants;
		import com.random.iso.characters.monsters.MonsterCharacter;
		import com.random.iso.characters.avatar.LayerCharacter;
		import com.random.iso.consts.*;
		import com.random.game.consts.RealmConsts;
		import org.flixel.FlxSound;
		import com.random.game.consts.Globals;
		import com.random.iso.utils.NumberUtil;
		import com.random.game.items.MonsterBag;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class AdventureManager extends MyRealmObjManager
	{
		
		protected var m_Combat:CombatController;
		public function AdventureManager() 
		{	
			m_Adventuring = true;
			super()
		}
		
		override protected function init():void {
			super.init();
			m_Combat = new CombatController(this);
		}
		
		//recieve mouse click events from the engine
		override public function onClick(mousex:int,mousey:int):void {
           
			var clickedTile:Tile;
			if (!m_AvatarGo) return;
			if (m_Combat.PrepareToFight) return;
			if (m_Combat.Fighting) return;
			
			m_Combat.unRegisterFight();
			m_PathtoDoor = null;
			m_PathToMainChest = null;
			m_PathToActivateObj = null;

			if (m_CurrentSelected == null)
			{ //clicked on a tile
				//goto the tile under the mouse
				clickedTile = m_Map.getTileFromScreenCoordinates( mousex, mousey );
				if( clickedTile) onTileClicked(clickedTile);	
				
			}else
			{//clicked object
				if (m_CurrentSelected is MonsterCharacter)
				{
					if (MonsterCharacter(m_CurrentSelected).Status == StatusConstants.ALIVE)
					{	
						//tell the mob to stand still and wait
						m_CurrentSelected.onMouseClick(mousex, mousey);
						//get read to fight
						m_Combat.registerFight(MonsterCharacter(m_CurrentSelected), CombatConstants.MONSTER_DEFEND);
						clickedTile = m_Map.getTile(m_CurrentSelected.xPos, m_CurrentSelected.yPos);
						if ( clickedTile) onTileClicked(clickedTile);	
						return;
					}
				}
				
				if (m_CurrentSelected is ChestObject)
				{
					m_PathToMainChest = ChestObject(m_CurrentSelected);
					//goto the tile the current item is on
					clickedTile = m_Map.getTile(m_CurrentSelected.xPos, m_CurrentSelected.yPos);
					if ( clickedTile) onTileClicked(clickedTile);	
					return;
				}
				
				if (m_CurrentSelected is ActivateObject)
				{
					m_PathToActivateObj = ActivateObject(m_CurrentSelected);
					//goto the tile the current item is on
					clickedTile = m_Map.getTile(m_CurrentSelected.xPos, m_CurrentSelected.yPos);
					if ( clickedTile) onTileClicked(clickedTile);	
					return;
					
				}
				if (m_CurrentSelected is DoorObject)
				{
					//set the door to use
					m_PathtoDoor = DoorObject(m_CurrentSelected);
					//goto the tile the current item is on
					clickedTile = m_Map.getTile(m_CurrentSelected.xPos, m_CurrentSelected.yPos);
					if ( clickedTile) onTileClicked(clickedTile);	
					return;
				}
				
				//goto the tile the current item is on
				//clickedTile = m_Map.getTile(m_CurrentSelected.xPos, m_CurrentSelected.yPos);
				//in adventure mode just go to the clicked tile
				clickedTile = m_Map.getTileFromScreenCoordinates( mousex, mousey );
				if ( clickedTile) onTileClicked(clickedTile);	
			}
			
			//e.stopImmediatePropagation();
            //e.stopPropagation();
			//if (_itemBeingDragged == null) {
				//m_map.boardInteractedWith(mousex, mousey);
			//} else if (_itemBeingDragged != null) {
			//	attemptPlaceItem(mouseX, mouseY);
			//}
		}     
		
		override public function onMouseMove(mousex:int, mousey:int):void {
			super.onMouseMove(mousex, mousey);
		}
		
		
		override public function changeRoom(door:DoorObject):void {
			m_Combat.stop();
			super.changeRoom(door);
			/*
			if (m_Adventuring && !RealmObj.CurrentRoom.EmptySpawn)
			{
				if (getMonsterCount() == 0)
				{
					
					var rand:Number = NumberUtil.randBetween(0, 1);
					
					if (rand < 0.55)
					{//spawn a random monster
						spawnRandomMonster();
					}else
					{//spawn loot bag
						loadBag();
					}
					
				}
				RealmObj.CurrentRoom.EmptySpawn = true;
			}
			*/
		}
		
		private function loadBag():void {
			
			var xml:XML = XML("<clickable file=\"/assets/special/monster_bag.png\" itemid=\"19419\" xpos=\"3\" ypos=\"3\" layer=\"2\" walkable=\"false\" overlap=\"false\" facings=\"1\" direction=\"SE\" width=\"64\" height=\"70\"><SE_Activate x_offset=\"-31\" y_offset=\"-42\" rows=\"1\" cols=\"1\" frames=\"6\" fps=\"15\" animation=\"loop\">0,1,2,3,4,5</SE_Activate><SE_Default x_offset=\"-31\" y_offset=\"-42\" rows=\"1\" cols=\"1\" frames=\"6\" fps=\"8\" animation=\"loop\">0,1,2,3,4,5</SE_Default><property id=\"254\" type=\"10\" itemstatus=\"0\" itemname=\"Magic Bag\" tooltip=\"Magic Bag\" coincost=\"1\" sell=\"0\" res=\"0\" restype=\"0\" iconfile=\"/assets/ui/icons/fantasy/well_02.jpg\"/></clickable>");
			
			var item:MonsterBag = new MonsterBag(false,this);
			item.loadFromXML(xml);
			
			var pnt:Point = m_Map.getEmptyTileFromCenter();
			m_Map.removeItem(item);
			if (pnt != null)
				item.setPosition(pnt.x, pnt.y);
			else
				item.setPosition(3, 3);
			m_Map.placeItem(item);
			sortLifeLayer();
		}
		
		private function loadPotion():void {
			
			var xml:XML = XML("<Charon-XML><header id=\"Monster_Bag_Results\"><date></date><status>Success</status></header><dataset><clickable file=\"/assets/special/potionshelf.png\" itemid=\"19420\" xpos=\"2\" ypos=\"5\" layer=\"2\" walkable=\"false\" overlap=\"false\" facings=\"1\" direction=\"SE\" width=\"61\" height=\"116\"><SE_Activate x_offset=\"-30\" y_offset=\"-85\" rows=\"1\" cols=\"1\" frames=\"1\" fps=\"8\" animation=\"activate\">0</SE_Activate><SE_Default x_offset=\"-30\" y_offset=\"-85\" rows=\"1\" cols=\"1\" frames=\"1\" fps=\"8\" animation=\"activate\">0</SE_Default><property id=\"255\" type=\"10\" itemstatus=\"0\" itemname=\"Potion Shelf\" tooltip=\"Potion Shelf\" coincost=\"1\" sell=\"0\" res=\"0\" restype=\"0\" iconfile=\"/assets/ui/icons/fantasy/shelf_01.jpg\"/></clickable></dataset></Charon-XML>");
			var item:GameObject = null;
			
			item = loadEditorItem(xml);	
			
			var pnt:Point = m_Map.getEmptyTileFromCenter();
			m_Map.removeItem(item);
			if (pnt != null)
				item.setPosition(pnt.x, pnt.y);
			else
				item.setPosition(3, 3);
			m_Map.placeItem(item);
			sortLifeLayer();
		}
		
		override public function reloadRoom():void {
			m_AvatartStart = m_AvatarLastDoor;
			m_Combat.stop();
			super.reloadRoom();
			
		}
		
		public function handlePotionPurchase(purchase:Boolean):void {
			if (m_PlayerDefeated)
			{
				if (purchase)
					reloadRoom();	
				else
					m_MsgBoxManager.showPlayerDefeat();
			}
		}
		
			//updates that need to be called before rendering the scene
		override public function updateBeforeRender():void 
		{
			if (!m_MapRenderReady) return; 
			
			super.updateBeforeRender();
			m_Combat.update();
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
					m_Combat.render();
					break;
				case 4://Roof
					super.render(layer);
					break;
			}
		}
		
		//stepped on a tile see if something needs to happen
		override protected function checkForTileEvents(tile:Tile):Boolean 
		{
			super.checkForTileEvents(tile);
			
			var indx:int = 0;
			
			if (tile.ItemsList.length > 1)
			{ //if there ar lots of items then get the monsters first
				for (var iloop:int = 0; iloop < tile.ItemsList.length - 1; iloop++)
					if (tile.ItemsList[iloop] is MonsterCharacter)
					{
						indx = iloop;
						break;
					}	
			}
		
			//hit a trap?
			if (tile.ItemsList[indx] is TrapObject)
			{
				var trap:TrapObject = TrapObject(tile.ItemsList[indx]);
				//going to a fight but ran into trap on the way
				if (!m_Combat.isRegistered())
				{
					if (trap.attackPlayer(m_Avatar))
					{
						m_Avatar.onStopMoving();	
						var url:String = GameConstants.RESOURCE_BASE + RealmConsts.TRAP + trap.ObjectID;
						var xmlLoader:URLLoader = new URLLoader();
						xmlLoader.addEventListener(Event.COMPLETE, onTrapComplete);
						xmlLoader.load(new URLRequest(url));	
						sortLifeLayer();
					}
				}
				
				return true;
			}
			
			//a moster has noticed
			if (tile.ItemsList[indx] is MonsterCharacter)
			{
				var mob:MonsterCharacter = tile.ItemsList[indx];
				if (mob.Status == StatusConstants.DEAD) return false;
				
				if (m_Combat.isRegistered()) { //player headed to a fight	
					if (mob.OwnerItemId == m_Combat.getRegMonster().OwnerItemId) return false; //im there
					//someone else wants to fight first
					m_Combat.unRegisterFight();
				}
				//stop the player in his tracks	
				m_Avatar.onStopMoving();
				//send the mob to attack
				mob.changeAI(AIConstants.ATTACK);
				//notify the combat engine
				m_Combat.registerFight(mob, CombatConstants.MONSTER_ATTACK);
				return true;
			}
			
			return false;
		}
		
		override public function setupAvatar():void {
			if (m_AvatartStart > 0)
			{//start by the door you just came through
				var xpos:int = int(m_Realm.CurrentRoom.Data.objects.Doors.doorobj.(@link == m_AvatartStart).@xpos);
				var ypos:int = int(m_Realm.CurrentRoom.Data.objects.Doors.doorobj.(@link == m_AvatartStart).@ypos);

				m_Avatar.setPosition(xpos, ypos);
				m_AvatarLastDoor = m_AvatartStart;
				m_AvatartStart = 0;
			}else
			{//no specific place to start
				m_Avatar.setDir(IsoConstants.DIR_SW);

				var pnt:Point = m_Map.getEmptyTile();
				if (pnt != null)
					m_Avatar.setPosition(pnt.x, pnt.y);
				else
					m_Avatar.setPosition(3, 3);
			}
			
			m_Avatar.doAction(ActionConstants.IDLE);
			m_LayerTwoList.push(m_Avatar);
			sortLifeLayer();
			m_MobileObjList.push(m_Avatar);
			m_Avatar.wakeUp();
			m_Avatar.Visible = true;
			m_AvatarGo = true;
			
			m_Combat.stop();
			m_PathtoDoor = null;
			m_PathToMainChest = null;
			m_PathToActivateObj = null;
			
			if (m_Adventuring && !RealmObj.CurrentRoom.EmptySpawn)
			{
				if (getMonsterCount() == 0)
				{
					
					var rand:Number = NumberUtil.randBetween(0, 1);
					
					if (rand < 0.55)
					{//spawn a random monster
						spawnRandomMonster();
					}else
					{//spawn loot bag
						loadBag();
					}
					
				}
				RealmObj.CurrentRoom.EmptySpawn = true;
			}
			
			
		}
		
		public function onTrapComplete(e:Event):void
		{
			/*
			 <?xml version="1.0"?>
			<Charon-XML>
				<header id="Combat_Results">
				<date>Tue Apr 27 23:38:56 CDT 2010</date>
				<status>Success</status>
				</header>
				<dataset>
					<combat outcome="0" loss="2" remaining="4" duration="3" />
					<reward type="0" value="6" />
					<reward type="2" value="170" />
				</dataset>
			</Charon-XML>
			 */
			var combatXML:XML;
			var outcome:int;
			var loss:int;
			var enrgy:int;
			var rewardList:XMLList;
			
			combatXML = XML(e.target.data);

			rewardList = combatXML.dataset.reward; 
			outcome = int(combatXML.dataset.combat.@outcome);
			
			if (outcome == 0)
			{
				
				loss = int(combatXML.dataset.combat.@loss);
				removePlayerEnergy(loss, true);
				
				enrgy = int(combatXML.dataset.combat.@remaining);
				setPlayerEnergy(enrgy);
				var reward:String;
				
				for each (var elem:XML in rewardList)
				{
					reward = elem.@type;
					switch (reward)
					{
						case "0": //Exp
							addPlayerXp(elem.@value, true);
							break;
						case "1"://Level
							setPlayerLevel(elem.@value, true);
							break;
						case "2"://Gold
							addPlayerGold(elem.@value, true);
							break;
						case "3"://Energy
							addPlayerEnergy(elem.@value, true);
							break;
						case "4"://Item
						break;
						
					}
				}
				
			}else
			{
				loss = int(combatXML.dataset.combat.@loss);
				removePlayerEnergy(loss, true);
				setPlayerEnergy(0);
				playerDefeat(true);
			}
		}
		
		//this is where I was going or as close and I am going to get
		override protected function checkForOnStopEvent(mob:MobileObject):void
		{
			super.checkForOnStopEvent(mob);
			if (m_Combat.isRegistered() && m_Combat.getRegMonster().OwnerItemId == mob.OwnerItemId)
			{//start the fight if one is waiting
				if (m_Combat.getStatus() == CombatConstants.MONSTER_ATTACK)
					m_Combat.beginFight();
			}
			
		}
	
		//this is where I was going or as close and I am going to get
		override protected function checkForAvatarOnStopEvent(mob:MobileObject):void{
			
			sortLifeLayer();
			if (m_Combat.isRegistered())
			{//start the fight if one is waiting
				if (m_Combat.getStatus() == CombatConstants.MONSTER_DEFEND)
				{
					m_Combat.beginFight();
					//forget about the door and fight
					m_PathtoDoor = null;
					m_PathToMainChest = null;
					m_PathToActivateObj = null;
					return;
				}
			}
			super.checkForAvatarOnStopEvent(mob);
			
			if (m_PathtoDoor != null)
			{
				
				
				if (closeToObject(m_PathtoDoor))
				{
					//hide the avatar for the transistion
					m_Avatar.Visible = false;
					m_AvatartStart = m_Realm.CurrentRoomID;
					m_Avatar.setDir(m_PathtoDoor.Dir);
					//goto the nxt room
					changeRoom(m_PathtoDoor);
					m_PathtoDoor = null;
					return;
				}
				
			}
			
			if (m_PathToMainChest != null)
			{
				
				if (m_PathToMainChest.Status == "closed" && !m_Realm.ChestPopped)
				{	
					m_PathToMainChest.activate();
					m_Realm.ChestPopped = true;
				}
				m_PathToMainChest = null;
				return;
			}
			
			if (m_PathToActivateObj != null)
			{
				if (m_PathToActivateObj.Status == "closed")
				{	
					m_PathToActivateObj.activate();
				}
				m_PathToActivateObj = null;
			}
			
		}

		
		
	}

}