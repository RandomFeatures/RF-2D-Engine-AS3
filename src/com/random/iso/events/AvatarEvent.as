package com.random.iso.events 
{
	import com.random.iso.renderer.tile.Tile;
	import com.random.iso.lands.avatar.Avatar;
	import flash.events.Event;
	 
	/**
	 * ...
	 * @author Bruce Branscom
	 */
	public class AvatarEvent extends Event
	{
		
		public static const AVATAR_CLICKED:String = "avatarClicked";
		
		private var _avatar:Avatar;
		
		public function AvatarEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{			
			super ( type, false, false );
		}
		
		public function get avatar():Avatar { return _avatar; }
		
		public function set avatar(value:Avatar):void {
			_avatar = value;
		}
		
	}
	
}