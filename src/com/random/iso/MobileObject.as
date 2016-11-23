package com.random.iso
{
	import com.random.iso.GameObject;
	import com.random.iso.map.tile.WayPoint;
	import com.random.iso.utils.NumberUtil;
	import com.random.iso.consts.IsoConstants;
	import com.random.iso.consts.StatusConstants;
	import com.random.game.state.Adventure;

	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class MobileObject extends GameObject
	{
		protected var m_WalkSpeed:Number = .09;
		protected var m_WayPoints:Array;
		protected var m_WayPointIndex:int;
		protected var m_AngleIndex:int = 1;
		protected var m_Angle:Number;
		protected var m_CosAngle:Number; 
		protected var m_SinAngle:Number;
		protected var m_CurrentAction:String;
		protected var m_PreviousAction:String;
		protected var m_CurrentStatus:String;
		protected var m_MobileType:String;
		protected var m_Visible:Boolean = true;
		protected var m_Moving:Boolean = false;
		
		public function MobileObject() 
		{
			super();
			m_CurrentStatus = StatusConstants.ALIVE;
		}
		
		public function get AngleIndex():int { return m_AngleIndex; }
		public function get Angle():Number { return m_Angle; }
		public function get CosAngle():Number { return m_CosAngle; }
		public function get SinAngle():Number { return m_SinAngle; }
		public function get CurrentAction():String { return m_CurrentAction; }
		public function set AngleIndex(value:int):void { m_AngleIndex = value; }
		public function set Angle(value:Number):void { m_Angle = value; }
		public function set CosAngle(value:Number):void { m_CosAngle = value; }
		public function set SinAngle(value:Number):void { m_SinAngle = value; }
		public function get WayPoints():Array { return m_WayPoints; }
		public function set WayPoints(value:Array):void { m_WayPoints = value; }
		public function get Status():String { return m_CurrentStatus; }
		public function set Status(value:String):void { m_CurrentStatus = value; }
		
		public function get Visible():Boolean { return m_Visible; }
		public function set Visible(value:Boolean):void { m_Visible = value;}
		
		public function get Moving():Boolean { return m_Moving; }
		public function set Moving(value:Boolean):void { m_Moving = value;}
		
		
		virtual public function walk(wayPoints:Array):void {
			m_Moving = true;
			m_WayPoints = wayPoints;
			m_WayPointIndex = 0;
		}
				
		public function get WalkSpeed():Number { return m_WalkSpeed; }
		public function set WalkSpeed(value:Number):void { m_WalkSpeed = value; }
		public function get WayPointIndex():int { return m_WayPointIndex; }
		public function set WayPointIndex(value:int):void {
			m_WayPointIndex = value;
			
			m_PosX = WayPoint(m_WayPoints[m_WayPointIndex]).LinkTile.Col;
			m_PosY = WayPoint(m_WayPoints[m_WayPointIndex]).LinkTile.Row;
			
			if (m_WayPointIndex < m_WayPoints.length-1) {
				var wp1:WayPoint = m_WayPoints[m_WayPointIndex];
				var wp2:WayPoint = m_WayPoints[m_WayPointIndex + 1];
				
				var ang_rad:Number = Math.atan2(wp2.LinkTile.Row - wp1.LinkTile.Row, wp2.LinkTile.Col - wp1.LinkTile.Col);
				m_CosAngle = Math.cos(ang_rad);
				m_SinAngle = Math.sin(ang_rad);
				
				m_Angle = ang_rad * 180 / Math.PI;
				
				m_AngleIndex = NumberUtil.findAngleIndex(m_Angle, 45);
			
				switch (m_AngleIndex)
				{
					case 0:
						setDir(IsoConstants.DIR_SE)
						break;
					case 2:
						setDir(IsoConstants.DIR_SW)
						break;
					case 4:
						setDir(IsoConstants.DIR_NW)
						break;
					case 6:
						setDir(IsoConstants.DIR_NE)
						break;
				}

				
			}
		}
		public function doAction(action:String):void
		{
			m_PreviousAction = m_CurrentAction;
			m_CurrentAction = action;
		}
		
		virtual public function isLoaded():Boolean { return true; }
		virtual public function onStopMoving():void { m_Moving = false; }
		
	}

}