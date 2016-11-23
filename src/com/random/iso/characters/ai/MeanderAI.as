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
	public class MeanderAI extends BasicAI
	{
		
		private var m_Mob:MonsterCharacter;
		private var m_TileList:Array;
		private var m_Moving:Boolean = false;
		private var m_Thinking:Boolean = false;
		private var m_Doing:Boolean = false;
		private var m_Waiting:Boolean = false;
		
		public function MeanderAI(mob:MonsterCharacter, game:GameObjectManager) 
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
			var wait:int = (3000 + (10000 - 3000)) * Math.random()
			setTimeout(meander, wait);
		}
		//mob has stopped
		override public function onStopMoving():void { 
			super.onStopMoving();
			m_Doing = false;
		} 
		
		
		
		
		//pick a random spot and wander over to it.
		private function meander():void
		{
			if (m_Stopped) return;
			
			m_Thinking = true;
			var tilearray:Array = m_Mob.getTilesList();
			
			if  (tilearray.length > 0)
			{
				var randomtile:int = (tilearray.length - 1) * Math.random();
				
				var tile:Tile = tilearray[randomtile];
				if (tile)
				{
					var path:Array = m_Game.getAStarPath(m_Mob, tile);
				}
				if (path) 
				{
					m_Doing = true;
					m_Game.walkMobile(m_Mob, path);
				}
				
			}
			m_Thinking = false;
			m_Waiting = false
		}
	
		
	}

}