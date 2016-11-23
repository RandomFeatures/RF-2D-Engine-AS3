package com.random.iso.characters.ai 
{
	
	import com.random.iso.characters.monsters.MonsterCharacter;
	import com.random.iso.characters.ai.BasicAI
	import com.random.iso.GameObjectManager;
	import com.random.iso.map.tile.Tile;
	import com.random.iso.consts.ActionConstants;
	import com.random.iso.GameObject;
	import org.flixel.FlxG;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class DeathAI extends BasicAI
	{
		private var m_Mob:MonsterCharacter;
		private var m_Delay:Number;
		private var m_Fading:Boolean = false;
		
		public function DeathAI(mob:MonsterCharacter, game:GameObjectManager) 
		{
			super(game);
			m_Mob = mob;
		}
		
		
		override public function update():void {
			if (m_Stopped) return;
			if (m_Fading)
			{
				m_Mob.Alpha -= FlxG.elapsed / m_Delay;
				if(m_Mob.Alpha <= 0)
				{
					m_Mob.Alpha = 0;
					//Remove from the world
					m_Game.removeItem(m_Mob, true);
					stop();
				}	
			}else
			{
				m_Mob.doAction(ActionConstants.IDLE);
				m_Delay = 2.5;//about 3 seconds
				m_Mob.Alpha = 1;
				m_Fading = true;
				//get me off the map
				m_Game.Map.removeMonster(m_Mob);
			}
		}
	}

}