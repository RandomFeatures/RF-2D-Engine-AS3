package com.random.iso.utils {
	
	/**
	 * Represents an point in isometric 3d space
	 * ...
	 * @author Allen Halsted
	 */
	public class IsoPoint {
		
		private var m_x:Number;
		private var m_y:Number;
		private var m_z:Number;
		
		public function IsoPoint(x:Number = 0, y:Number = 0, z:Number = 0):void {
			m_x = x;
			m_y = y;
			m_z = z;
		}
		
		public function get X():Number { return m_x; }
		public function set X(value:Number):void { m_x = value;	}
		
		public function get Y():Number { return m_y; }
		public function set Y(value:Number):void { m_y = value;	}
		
		public function get Z():Number { return m_z; }		
		public function set Z(value:Number):void {	m_z = value; }
		
	}
	
}