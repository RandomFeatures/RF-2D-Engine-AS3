package com.random.iso.events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class MenuEvent extends Event
	{
		public static const ITEM_CLICKED:String = "ITEM_CLICKED";
		private var m_CurrentSelected:Object;
		private var m_Action:String;
		
		
		public function MenuEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super ( type, false, false );
		}
		public function set CurrentSelected(value:Object):void {
			m_CurrentSelected = value;
		}
		public function get CurrentSelected():Object {
			return m_CurrentSelected;
		}
		
		public function set Action(value:String):void { m_Action = value; }
		public function get Action():String { return m_Action; }
	}

}