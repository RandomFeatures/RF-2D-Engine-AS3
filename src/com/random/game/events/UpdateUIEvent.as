package com.random.game.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class UpdateUIEvent extends Event
	{
		private var m_strData:String;
		
		public function UpdateUIEvent(type:String="", bubbles:Boolean = false, cancelable:Boolean = false) : void {
			super(type, bubbles, cancelable);
			m_strData = "";
		}
			
		public function set Data(value:String):void { m_strData = value; }
		public function get Data():String { return m_strData; }
		
	}

}