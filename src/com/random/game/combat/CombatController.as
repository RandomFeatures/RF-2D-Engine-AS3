package com.random.game.combat
{
	import com.random.iso.characters.monsters.MonsterCharacter;
	import com.random.game.MyRealmObjManager;
	import com.random.game.consts.RealmConsts;
	import com.random.iso.consts.AIConstants;
	import com.random.iso.consts.ActionConstants;
	import com.random.iso.characters.avatar.LayerCharacter;
	import flash.utils.setTimeout;
	import org.flixel.FlxSprite;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import com.random.game.AvatarStats;
	import com.random.game.UI.MsgBoxManager;
	import org.flixel.FlxSound;
	import com.random.game.consts.SoundFiles;
	import com.random.game.consts.Globals;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class CombatController
	{
		private var m_Game:MyRealmObjManager;
		private var m_Mob:MonsterCharacter = null;
		private var m_Registered:Boolean = false;
		private var m_CombatStatus:String;
		private var m_FightCloud:FlxSprite;
		private var m_Fighting:Boolean = false;
		private var m_RewardList:XMLList;
		private var m_ElapsedTime:int = 0;
		private var m_FightDuration:int = 5;
		private var m_FightWon:Boolean = false;
		private var m_FightCount:int = 0;
		private var m_PowerLost:int = 0;
		private var m_SfxFight:FlxSound;
		private var m_SfxWon:FlxSound;
		private var m_SfxLost:FlxSound;
		private var xmlLoader:URLLoader;
		
		
		public function CombatController(game:MyRealmObjManager) 
		{
			m_Game = game;
		}
		
		public function get Fighting():Boolean { return m_Fighting; }
		public function get PrepareToFight():Boolean { return m_Registered; }
		//wait 3 to 10 seconds and go again
		private function waitTime():void {
			
			if (!m_Fighting) return;
			
			setTimeout(doFight, 1000);
			m_FightCount++;
			
			if (m_FightCount > 10 && m_Fighting) //enough we are done
			 completeCombat(XML("<?xml version=\"1.0\"?><Charon-XML><header id=\"Combat_Results\"><date>Tue Apr 27 23:38:56 CDT 2010</date><status>Success</status></header><dataset><combat outcome=\"0\" loss=\"2\" remaining=\"4\" duration=\"1\" /></dataset></Charon-XML>"));
			  
		}
		
		public function getStatus():String { return m_CombatStatus; }
		public function getRegMonster():MonsterCharacter { return m_Mob; }
		public function stop():void {
			if (m_Mob != null)
			{
				m_Mob.changeAI(AIConstants.MEANDER);
			}
			
			m_Mob = null;
			m_Registered = false;
			m_Fighting = false;
		}
		public function unRegisterFight():void
		{
			if (m_Fighting) return;
			if (m_Mob != null)
			{
				m_Mob.changeAI(AIConstants.MEANDER);
			}
			
			m_Mob = null;
			m_Registered = false;
		}
		
		public function registerFight(mob:MonsterCharacter, status:String):void {
			if (m_Fighting) return;
			if (m_Mob == null)
			{
				m_Mob = mob;
				m_Registered = true;
				m_CombatStatus = status;
			}
		}
		
		public function isRegistered():Boolean {
			return m_Registered;
		}
		
		//GameConstants.RESOURCE_BASE + GameConstants.COMBAT
		
		public function beginFight():void {
			if (m_Fighting) return;
			
			if (m_Mob && m_Registered)
			{
				var url:String = Globals.RESOURCE_BASE + RealmConsts.COMBAT + m_Mob.ObjectID;
				xmlLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, onCombatComplete);
				xmlLoader.load(new URLRequest(url));	
				m_Mob.Visible = false;
				m_Registered = false;
				m_Game.Avatar.Visible = false;
				//m_Mob.attack(m_Game.Avatar);
				//m_Game.Avatar.attack(m_Mob);
				m_Fighting = true;
				waitTime();
			}
		}

		private function onCombatComplete(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			xmlLoader.removeEventListener(Event.COMPLETE, onCombatComplete);
			if (xml.header.status == "Success")
				completeCombat(XML(e.target.data));

		}
		
		private function completeCombat(xml:XML):void {
		/*
			 <?xml version="1.0"?>
			<Charon-XML>
				<header id="Combat_Results">
				<date>Tue Apr 27 23:38:56 CDT 2010</date>
				<status>Success</status>
				</header>
				<dataset>
					<combat outcome="0" loss="2" remaining="4" duration="3" />
					<stats gender="1" experince="388" level="3" gold="5391" bucks="5" maxenergy="500" energy="405" recharge="1" />
					<reward type="0" value="6" />
					<reward type="2" value="170" />
				</dataset>
			</Charon-XML>
			 */
			var combatXML:XML;
			var outcome:int;
			
			combatXML = xml;
			m_RewardList = combatXML.dataset.reward; 
			m_FightDuration = int(combatXML.dataset.combat.@duration);
			outcome = int(combatXML.dataset.combat.@outcome);
			
			AvatarStats.loadFromStatsXML(combatXML);
			
			if (outcome == 0)
			{
				m_FightDuration += 3;
				m_FightWon = true;
				m_PowerLost = int(combatXML.dataset.combat.@loss);
				spawnGold();
			}else
			{
				m_FightWon = false;
				m_PowerLost = int(combatXML.dataset.combat.@loss);
			}	
		}
		
		private function spawnGold():void {
			var reward:String;
			//trace("spawn Gold");
			for each (var elem:XML in m_RewardList)
			{
				reward = elem.@type;
				switch (reward)
				{
					case "2"://Gold
						//m_Game.showPlayerGainGold(elem.@value);
						//trace("Gold: " + elem.@value);
						return;
						break;
				}
			}
		}
		
		private function finishFight():void {
			if (!m_Fighting) return;
			
			if (m_Mob)
			{
				m_SfxFight.stop();
				if (m_FightWon)
				{
					m_Mob.die();
					m_Game.RealmObj.CurrentRoom.addDeadMonster(m_Mob.OwnerItemId);
					m_Game.Avatar.doAction(ActionConstants.IDLE);
					m_Game.Avatar.Visible = true;
					m_Mob = null;
					m_Registered = false;
					m_Game.showPlayerEnrgy(m_PowerLost);
					var reward:String;
					for each (var elem:XML in m_RewardList)
					{
						reward = elem.@type;
						switch (reward)
						{
							case "0": //Exp
								m_Game.showPlayerGainXp(elem.@value);
								break;
							case "1"://Level
								m_Game.showPlayerGainLevel(elem.@value);
								break;
							case "2"://Gold
								//m_Game.showPlayerGainGold(elem.@value);
								break;
							case "3"://Energy
								m_Game.showPlayerEnrgy(elem.@value);
								break;
							case "4"://Item
							break;
							case "5"://Bucks
								m_Game.showPlayerGainBucks(elem.@value);
							break;
							case "6"://Full Power
								m_Game.showPlayerFullEnrgy();
							break;
							case "8"://Captured Monster
								m_Game.showCapturedMonster(elem.@value);
							break;

						}
					}
					
					m_Fighting = false;
					
				}else
				{
					//m_Mob.die();
					m_Game.Avatar.doAction(ActionConstants.IDLE);
					//m_Game.Avatar.Visible = true;
					m_Mob = null;
					m_Registered = false;
					m_Fighting = false;
					m_Game.showPlayerDefeatMessage();
				}
				
				m_Game.UpdateUIStats();				
			}
		}
		
		public function update():void {
			if (m_Fighting)
			{
			}
		}
		
		public function render():void {
			if (m_Fighting)
			{
			}
		}
		
		private function doFight():void {
			if (!m_Fighting) return;
			
			m_ElapsedTime += 1;
			
			if (m_ElapsedTime < m_FightDuration)
			{
				waitTime();
			}else
				finishFight();
			
		}
		
		
		
	}

}