package com.random.game
{
	import com.random.iso.GameStats;
	import flash.events.Event;
	import com.random.game.consts.RealmConsts;
	import com.random.game.events.UpdateUIEvent;
	import com.random.iso.consts.GameConstants;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class AvatarStats extends GameStats
	{
		
		public static var m_Exp:int = 0;
		public static var m_Level:int = 0;
		public static var m_Gold:int = 0;
		public static var m_Bucks:int = 0;
		public static var m_MaxEnergy:int = 0;
		public static var m_Energy:int = 0;
		public static var m_NextLevel:int = 0;
		public static var m_PrevLevel:int = 0;
		public static var m_Gender:int = 0;
		
		public function AvatarStats() 
		{
			
		}
		
		public function get Experince():int { return m_Exp; }
		public function get Level():int { return m_Level; }
		public function get Gold():int { return m_Gold; }
		public function get Bucks():int { return m_Bucks; }
		public function get MaxEnergy():int { return m_MaxEnergy; }
		public function get Energy():int { return m_Energy; }
		public function get NextLevel():int { return m_NextLevel; }
		public function get PrevLevel():int { return m_PrevLevel; }
		public function get Gender():int { return m_Gender; }
		
		public function set Experince(value:int):void { m_Exp = value; updateUI(); }
		public function set Level(value:int):void {  m_Level = value; updateUI(); }
		public function set Gold(value:int):void { m_Gold = value; updateUI(); }
		public function set Bucks(value:int):void { m_Bucks = value; updateUI(); }
		public function set MaxEnergy(value:int):void { m_MaxEnergy = value; updateUI(); }
		public function set Energy(value:int):void 
		{ 
			m_Energy = value; 
			if (m_Energy > m_MaxEnergy)
					m_Energy = m_MaxEnergy; 
			if (m_Energy < 0)
					m_Energy = 0;
			updateUI();
		}
		public function set NextLevel(value:int):void { m_NextLevel = value; updateUI(); }
		public function set PrevLevel(value:int):void { m_PrevLevel = value; updateUI(); }
		
		
		public function addExperince(plusValue:int):void { m_Exp += plusValue; updateUI(); }
		public function addLevel(plusValue:int):void { m_Level += plusValue; updateUI(); }
		public function addGold(plusValue:int):void { m_Gold += plusValue; updateUI(); }
		public function addBucks(plusValue:int):void { m_Bucks += plusValue; updateUI(); }
		public function addEnergy(plusValue:int):void { 
			if (m_Energy < m_MaxEnergy) 
			{ 
				m_Energy += plusValue;
				if (m_Energy > m_MaxEnergy)
					m_Energy = m_MaxEnergy; 
				if (m_Energy < 0)
					m_Energy = 0;
				updateUI(); 
			} 
		}
		
		public function loseExperince(minusValue:int):void { m_Exp -= minusValue; updateUI(); }
		public function loseLevel(minusValue:int):void { m_Level -= minusValue; updateUI();	}
		public function loseGold(minusValue:int):void {	m_Gold -= minusValue; updateUI(); }
		public function loseBucks(minusValue:int):void { m_Bucks -= minusValue; updateUI();	}
		public function loseEnergy(minusValue:int):void 
		{ 
			m_Energy -= minusValue; 
			if (m_Energy > m_MaxEnergy)
					m_Energy = m_MaxEnergy; 
			if (m_Energy < 0)
					m_Energy = 0;
			updateUI(); 
		}
		
		
		public function updateExperince(value:int):void { m_Exp += value; updateUI(); }
		public function updateLevel(value:int):void { m_Level += value; updateUI();	}
		public function updateGold(value:int):void { m_Gold += value; updateUI(); }
		public function updateBucks(value:int):void { m_Bucks += value; updateUI();	}
		public function updateEnergy(value:int):void { 
			m_Energy += value; 
			if (m_Energy > m_MaxEnergy)
					m_Energy = m_MaxEnergy; 
			if (m_Energy < 0)
					m_Energy = 0;
			
			updateUI(); 
		}
		
		public function toXML():XML 
		{
			return XML(toXMLString);
		}	
		
		public function toXMLString():String
		{
			var stats:String;
			stats = "<stats><gold>"+m_Gold+"</gold><level>"+m_Level+"</level><bucks>"+m_Bucks+"</bucks><exp>"+m_Exp+"</exp><expprev>"+m_PrevLevel+"</expprev><expmax>"+m_NextLevel+"</expmax><pow>"+m_Energy+"</pow><powmax>"+m_MaxEnergy+"</powmax></stats>";
			GameConstants.STATS_XML = stats;
			
			return stats;
		}	
		
		override public function setXMLString():void {
			
			if (GameConstants.STATS_XML != "")
			{
				var xml:XML = XML(GameConstants.STATS_XML);
				
				m_Exp = int(xml.exp);
				m_Level = int(xml.level);
				m_Gold = int(xml.gold);
				m_Bucks = int(xml.bucks);
				m_MaxEnergy = int(xml.powmax);
				m_Energy = int(xml.pow);
				m_NextLevel = int(xml.expmax);
				m_PrevLevel = int(xml.expprev);
				updateUI();
			}
		}
		
		
		override public function updateUI():void {
			// send the update to the header ui to display
			
			var evnt:UpdateUIEvent;
			evnt = new UpdateUIEvent(RealmConsts.UPDATE_HEADER, true, false);
			evnt.Data = toXMLString();
			dispatchEvent(evnt);
		}
		
		public static function loadFromStatsXML(xml:XML):void
		{
			m_Exp = int(xml.dataset.stats.@experince);
			m_Level = int(xml.dataset.stats.@level);
			m_Gold = int(xml.dataset.stats.@gold);
			m_Bucks = int(xml.dataset.stats.@bucks);
			m_MaxEnergy = int(xml.dataset.stats.@maxenergy);
			m_Energy = int(xml.dataset.stats.@energy);
			m_NextLevel = int(xml.dataset.stats.@nextlevel);
			m_PrevLevel = int(xml.dataset.stats.@thislevel);
			m_Gender = int(xml.dataset.stats.@gender);

			if (m_Energy < 0)
				m_Energy = 0;	
		}

		override public function loadFromXML(xml:XML):void
		{
			m_Exp = int(xml.dataset.Avatar.stats.@experince);
			m_Level = int(xml.dataset.Avatar.stats.@level);
			m_Gold = int(xml.dataset.Avatar.stats.@gold);
			m_Bucks = int(xml.dataset.Avatar.stats.@bucks);
			m_MaxEnergy = int(xml.dataset.Avatar.stats.@maxenergy);
			m_Energy = int(xml.dataset.Avatar.stats.@energy);
			m_NextLevel = int(xml.dataset.Avatar.stats.@nextlevel);
			m_PrevLevel = int(xml.dataset.Avatar.stats.@thislevel);
			m_Gender = int(xml.dataset.Avatar.stats.@gender);
			
			if (m_Energy < 0)
				m_Energy = 0;
			
			updateUI();
		}
	}

}