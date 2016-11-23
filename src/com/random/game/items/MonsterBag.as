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
	public class MonsterBag extends ActivateObject
	{
		protected var m_MyRealm:MyRealmObjManager;
		private var m_xmlLoader:URLLoader;
		public function MonsterBag(editMode:Boolean, game:MyRealmObjManager) 
		{
			m_GlowEffect = new GlowFilter(0x00009900);
			m_MyRealm = game;
			super(editMode, game);
			ToolTip = "Left click to look inside this bag."
			
			
			
		}
		
		override public function activate():void {
			
			var url:String = Globals.RESOURCE_BASE + RealmConsts.MONSTERBAG + m_MyRealm.RealmObj.RealmID;
			m_xmlLoader = new URLLoader();
			m_xmlLoader.addEventListener(Event.COMPLETE, onPopComplete);
			m_xmlLoader.load(new URLRequest(url));
			ToolTips.hide();
			super.activate();
			
		}
		
		public function onPopComplete(e:Event):void {

			m_xmlLoader.removeEventListener(Event.COMPLETE, onPopComplete);
			m_xmlLoader = null;
			this.Enabled = false;
			//remove to life list
			m_Game.removeItem(this,true);

			var chestXML:XML = XML(e.target.data);
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
						case "3"://Energy
							m_MyRealm.showPlayerGainEnrgy(elem.@value);
							break;
						case "6"://Full Power
							m_MyRealm.showPlayerFullEnrgy();
							break;
						case "9"://Full Power
							m_MyRealm.spawnRandomMonster();
							break;	
						
					}
				}
				
				m_MyRealm.Stats.updateUI();
			}
				
		}
	}

}