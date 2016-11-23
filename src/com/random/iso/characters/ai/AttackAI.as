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
	public class AttackAI extends BasicAI
	{
		private var m_Mob:MonsterCharacter;
		private var m_TileList:Array;
		private var m_Moving:Boolean = false;
		private var m_Thinking:Boolean = false;
		private var m_Doing:Boolean = false;
		private var m_Waiting:Boolean = false;
		
		public function AttackAI(mob:MonsterCharacter, game:GameObjectManager) 
		{
			super(game);
			m_Mob = mob;
		}
		
		override public function update():void {
			if (m_Thinking) return;
			if (m_Doing) return;
			if (m_Waiting) return;
			if (m_Stopped) return;
			
			moveToPlayer();
		}
		
		//mob has stopped
		override public function onStopMoving():void { 
			super.onStopMoving();
		} 
		
		//pick a random spot and wander over to it.
		private function moveToPlayer():void
		{
			if (m_Stopped) return;
			
			m_Thinking = true;
			var tile:Tile = m_Game.Map.getTile(m_Game.Avatar.xPos,m_Game.Avatar.yPos)
			
			if (tile) {
				var path:Array = m_Game.getAStarPath(m_Mob, tile);
			}
			if (path) {
				m_Doing = true;
				m_Game.walkMobile(m_Mob, path);
			}
			
			m_Thinking = false;
			m_Waiting = false
		}
		
	}

}