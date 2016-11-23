package com.random.iso
{
	
	import flash.events.Event;
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class GameState extends FlxState
	{
		
		private var m_EventsAssigned:Boolean = false;
	
		
		public function GameState() 
		{
			super();
		}
		
		
		override public function render():void
		{
			super.render();
		}
		
		override public function update():void
        {
			super.update();
			
			if(!m_EventsAssigned)
			{	
				if(FlxG.state == null) return;
				if(FlxG.state.parent == null) return;
				if (FlxG.state.parent.stage == null) return;
				assignEventListeners()
				m_EventsAssigned = true;
				
			}
			
		}
		
		
		virtual protected function assignEventListeners():void { }
		virtual protected function removeEventListeners():void { }	
		
	}

}