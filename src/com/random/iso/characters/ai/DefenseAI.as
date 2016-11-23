package com.random.iso.characters.ai 
{
	import com.random.iso.characters.monsters.MonsterCharacter;
	import com.random.iso.characters.ai.BasicAI
	import com.random.iso.GameObjectManager;
	import com.random.iso.map.tile.Tile;
	import com.random.iso.GameObject;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class DefenseAI extends BasicAI
	{
		private var m_Mob:MonsterCharacter;
		private var m_TileList:Array;
		private var m_Moving:Boolean = false;
		private var m_Thinking:Boolean = false;
		private var m_Doing:Boolean = false;
		private var m_Waiting:Boolean = false;
		public function DefenseAI(mob:MonsterCharacter, game:GameObjectManager) 
		{
			super(game);
			m_Mob = mob;
		}

		override public function update():void {
			if (m_Thinking) return;
			if (m_Doing) return;
			if (m_Waiting) return;
			if (m_Stopped) return;
			
			waitTime();
		}
		
		//wait 3 to 10 seconds and go again
		private function waitTime():void {
			m_Waiting = true;
			var wait:int = 1000;
			setTimeout(facePlayer, wait);
		}
		
		private function facePlayer():void {
			if (m_Stopped) return;
			if (m_Game == null) return;
			if (m_Game.Avatar == null) return;
			if (m_Mob == null) return;
			
			m_Mob.faceTarget(m_Game.Avatar.xPos, m_Game.Avatar.yPos);
			m_Waiting = false;
		}
		
	}

}