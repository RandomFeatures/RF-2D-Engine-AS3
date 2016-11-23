package com.random.iso.map.tile {
	
	import com.random.iso.map.tile.Tile;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class WayPoint {
		
		private var m_Time:Number;
		private var m_Tile:Tile;
		
		public function WayPoint() {
			
		}
		
		public function get Time():Number { return m_Time; }
		public function set Time(value:Number):void { m_Time = value; }
		public function get LinkTile():Tile { return m_Tile; }		
		public function set LinkTile(value:Tile):void { m_Tile = value;	}
		
		
	}
	
}