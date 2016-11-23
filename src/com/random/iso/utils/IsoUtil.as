package com.random.iso.utils {
	import com.random.iso.utils.IsoPoint;
	import com.random.iso.consts.IsoConstants;
	/**
	 * Isometric math utility 
	 * @author Allen Halsted
	 */
	public class IsoUtil {
		
		//angles defining the point of view
		private var m_Theta:Number;
		private var m_Alpha:Number;
		
		//trigonometric values stored for later use
		private var m_SinTheta:Number;
		private var m_CosTheta:Number;
		private var m_SinAlpha:Number;
		private var m_CosAlpha:Number;
		
		/**
		 * Isometric class contrustor.
		 * @param	declination value. Defaults to the most common value, which is 30.
		 */
		public function IsoUtil() {
			m_Theta = IsoConstants.THETA;
			m_Alpha = IsoConstants.ALPHA;
			m_SinTheta = IsoConstants.SINTHETA;
			m_CosTheta =  IsoConstants.COSTHETA;
			m_SinAlpha =  IsoConstants.SINALPHA;
			m_CosAlpha =  IsoConstants.COSALPHA;
		}
		
		/**
		 * Maps 3D coordinates to the 2D screen
		 * @param	x coordinate
		 * @param	y coordinate
		 * @param	z coordinate
		 * @return	Coordinate instance containig screen x and screen y
		 */
		public function mapToScreen(xpp:Number, ypp:Number, zpp:Number):IsoPoint {
			var yp:Number = ypp;
			var xp:Number = xpp*m_CosAlpha+zpp*m_SinAlpha;
			var zp:Number = zpp*m_CosAlpha-xpp*m_SinAlpha;
			var x:Number = xp;
			var y:Number = yp*m_CosTheta-zp*m_SinTheta;
			return new IsoPoint(x, y, 0);
		}
		
		/**
		 * Maps 2D screen coordinates into 3D coordinates. It is assumed that the target 3D y coordinate is 0.
		 * @param	screen x coordinate
		 * @param	screen y coordinate
		 * @return	Coordinate instance containig 3D x, y, and z
		 */
		public function mapToIsoWorld(screenX:Number, screenY:Number):IsoPoint {
			var z:Number = (screenX/m_CosAlpha-screenY/(m_SinAlpha*m_SinTheta))*(1/(m_CosAlpha/m_SinAlpha+m_SinAlpha/m_CosAlpha));
			var x:Number = (1/m_CosAlpha)*(screenX-z*m_SinAlpha);
			return new IsoPoint(x, 0, z);
		}
		
	}
}