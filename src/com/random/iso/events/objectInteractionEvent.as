package com.random.iso.events {
	import com.random.iso.GameObject;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class objectInteractionEvent extends Event {
		
		public static const object_SELECTED:String = "objectSelected";
		public static const object_PLACED:String = "objectPlaced";
		public static const object_CLICKED:String = "objectClicked";
		
		
		private var _object:GameObject;
		
		public function objectInteractionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			
			super ( type, false, false );
		}
		
		public function get object():GameObject { return _object; }
		
		public function set object(value:GameObject):void {
			_object = value;
		}
		
		
	}
	
}