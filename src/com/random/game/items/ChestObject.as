package com.random.game.items 
{
	import com.random.iso.items.ActivateObject;
	import com.random.game.MyRealmObjManager;
	import flash.filters.GlowFilter;
	import com.random.game.consts.RealmConsts
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import com.random.iso.ui.ToolTips;
	import com.random.game.UI.MsgBoxManager;
	import org.flixel.FlxSound;
	import org.flixel.FlxG;
	import com.random.game.consts.StaticResources;
	import com.random.game.consts.SoundFiles;
	import com.random.game.consts.Globals;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class ChestObject extends ActivateObject
	{
		
		protected var m_MyRealm:MyRealmObjManager;
		private var m_xmlLoader:URLLoader;
		private var m_Delay:Number;
		private var m_Fading:Boolean = false;
		public function ChestObject(editMode:Boolean, game:MyRealmObjManager) 
		{
			m_GlowEffect = new GlowFilter(0x00009900);
			m_MyRealm = game;
			super(editMode, game);
			
			if (game.GameMode == 1)
				ToolTip = "Left click to open this treasure chest."
		}
		
		override public function activate():void {
			
			
			var url:String = Globals.RESOURCE_BASE + RealmConsts.POPCHEST + m_MyRealm.RealmObj.RealmID;
			m_xmlLoader = new URLLoader();
			m_xmlLoader.addEventListener(Event.COMPLETE, onPopComplete);
			m_xmlLoader.load(new URLRequest(url));
			ToolTips.hide();
			super.activate();
		}
		
		
			//update the image animation
		override public function update():void
		{
			super.update();
			
			if (m_Fading)
			{
				m_SpriteImage.alpha -= FlxG.elapsed/m_Delay;
				if(m_SpriteImage.alpha <= 0)
				{
					m_SpriteImage.alpha = 0;
					leaveGameWorld();
				}	
			}
		}
		
		public function fadeAway():void
		{
			m_Delay = 1;
			m_SpriteImage.alpha = 1;
			m_Fading = true;
		}
		
		public function leaveGameWorld():void
		{
			this.Enabled = false;
			//remove to life list
			m_Game.removeItem(this,true);
		}
		
		
		public function onPopComplete(e:Event):void {
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
			m_xmlLoader.removeEventListener(Event.COMPLETE, onPopComplete);
			m_xmlLoader = null;
			var chestXML:XML = XML(e.target.data);
			fadeAway();
			if (chestXML.header.status == "Success")
			{
				var m_RewardList:XMLList = chestXML.dataset.reward; 
				var loss:int = int(chestXML.dataset.combat.@loss);
				var enrgy:int = int(chestXML.dataset.combat.@remaining);
				
				var gold:int = 0;
				var reward:String;
				for each (var elem:XML in m_RewardList)
				{
					reward = elem.@type;
					switch (reward)
					{
						case "0": //Exp
							m_MyRealm.showPlayerGainXp(elem.@value);
							break;
						case "1"://Level
							m_MyRealm.showPlayerGainLevel(elem.@value);
							break;
						case "2"://Gold
							gold = elem.@value;
							m_MyRealm.showPlayerGainGold(gold);
							break;
						case "3"://Energy
							m_MyRealm.showPlayerEnrgy(elem.@value);
							break;
						case "4"://Item
						break;
						case "5"://Bucks
							m_MyRealm.showPlayerGainBucks(elem.@value);
							break;
						case "6"://Full Power
							m_MyRealm.showPlayerFullEnrgy();
							break;
					}
				}
				
				m_MyRealm.Stats.updateUI();
				
				if (gold > 0)
					m_MyRealm.MessageBoxManager.showOpenMasterChest(gold);
			}
				
		}
		
	}

}