package com.random.iso.events 
{
	import flash.events.Event;
	 
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class UIItemEvent extends Event
	{
		
		public static const ITEM_CLICKED:String = "itemClicked";

		private var _itemid:int;
		private var _imageURL:String;
		
		public function UIItemEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{			
			super ( type, false, false );
		}
		
		public function get ItemID():int { return _itemid; }
		public function set ItemID(value:int):void { _itemid = value; }
		
		public function get ImageURL():String { return _imageURL; }
		public function set ImageURL(value:String) { _imageURL = value; }
	}
	
}