package com.random.iso
{
	import org.flixel.FlxGame
	/**
	 * Base controller class from the engine for games to inherti from 
	 * It forces a few default settings for the engine
	 * ...
	 * @author Allen Halsted
	 */
	public class GameController extends FlxGame
	{
		 
		public function GameController(GameSizeX:uint,GameSizeY:uint,InitialState:Class,Zoom:uint=2) 
		{
			super(GameSizeX, GameSizeY, InitialState, Zoom); //Create a new FlxGame object, then load PlayState
			//showLogo = false;
		}
		
	}

}