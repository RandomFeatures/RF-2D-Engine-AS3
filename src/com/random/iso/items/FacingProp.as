package com.random.iso.items 
{
	import com.random.iso.consts.AnimationConstants;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class FacingProp
	{
		
		private var m_xOffset:int = 0;
		private var m_yOffset:int = 0;
		private var m_Rows:int = 1;
		private var m_Cols:int = 1;
		private var m_FrameCount:int = 1;
		private var m_AnimationType:String = "NONE"
		private var m_Frames:Array = [];
		private var m_Action:String = "SE_DEFAULT";
		private var m_LoopAnimation:Boolean  = false;
		private var m_FPS:Number = 10;
		public function FacingProp() 
		{
			
		}
		
		public function set xOffset(value:int):void { m_xOffset = value; }
		public function set yOffset(value:int):void { m_yOffset = value; }
		public function set Rows(value:int):void { m_Rows = value; }
		public function set Cols(value:int):void { m_Cols = value; }
		public function set FrameCount(value:int):void { m_FrameCount = value; }
		public function set AnimationType(value:String):void { 
			
			m_AnimationType = value; 
			if (value == "LOOP")
				m_LoopAnimation = true;
		}
		public function set Action(value:String):void { m_Action = value; }
		public function set FPS(value:Number):void { m_FPS = value; }
		
		public function setFrames(value:String):void { 
			var frames:Array = value.split(","); 
			
			for each (var s:String in frames)
				m_Frames.push(int(s));
		}
		
		public function get xOffset():int { return m_xOffset; }
		public function get yOffset():int { return m_yOffset; }
		public function get Rows():int { return m_Rows; }
		public function get Cols():int { return m_Cols; }
		public function get FrameCount():int { return m_FrameCount; }
		public function get AnimationType():String { return m_AnimationType; }
		public function get Action():String { return m_Action; }
		public function get Frames():Array { return m_Frames; }
		public function get Looped():Boolean { return m_LoopAnimation; }
		public function get FPS():Number { return m_FPS; }
		
	}

}