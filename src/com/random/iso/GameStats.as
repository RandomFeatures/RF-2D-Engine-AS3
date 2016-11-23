package com.random.iso
{
	import XML
	import flash.events.EventDispatcher
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class GameStats extends EventDispatcher
	{
		
		public function GameStats() 
		{
			
		}
		virtual public function loadFromXML(xml:XML):void { }
		virtual public function setXMLString():void { }
		virtual public function updateUI():void {}	
	}

}