package com.random.iso.characters.ai 
{
	import com.random.iso.characters.avatar.LayerCharacter;
	import com.random.iso.GameObjectManager;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class BasicAI
	{
		protected var m_Player:LayerCharacter;
		protected var m_Game:GameObjectManager;
		protected var m_Stopped:Boolean = true;
		public function BasicAI(game:GameObjectManager) 
		{
			m_Player = game.Avatar;
			m_Game = game;
		}
		virtual public function update():void { }
		virtual public function stop():void { m_Stopped = true; } 
		virtual public function start():void { m_Stopped = false; } 
		virtual public function onStopMoving():void { }
	}

}