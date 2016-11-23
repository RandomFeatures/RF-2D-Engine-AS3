package com.random.game.UI 
{
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class Cursor extends MovieClip
	{
		
		private var stageRef:Stage;
		private var p:Point = new Point(); //keeps up with last known mouse position
		
		public function Cursor(stageRef:Stage) 
		{
			Mouse.hide(); //make the mouse disappear
			mouseEnabled = false; //don't let our cursor block anything
			this.stageRef = stageRef;
			x = stageRef.mouseX;
			y = stageRef.mouseY;
 
			stageRef.addEventListener(MouseEvent.MOUSE_MOVE, updateMouse, false, 0, true);
			stageRef.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler, false, 0, true);

		}
		
		private function updateMouse(e:MouseEvent) : void
		{
			x = stageRef.mouseX;
			y = stageRef.mouseY;
 
			e.updateAfterEvent();
		}

		private function mouseLeaveHandler(e:Event) : void
		{
			visible = false;
			Mouse.show();
			stageRef.addEventListener(MouseEvent.MOUSE_MOVE, mouseReturnHandler, false, 0, true);
		}
 
		private function mouseReturnHandler(e:Event) : void
		{
			visible = true;
			Mouse.hide(); //in case of right click
			stageRef.removeEventListener(MouseEvent.MOUSE_MOVE, mouseReturnHandler);
		}
	}

}