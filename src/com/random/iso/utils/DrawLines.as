package com.random.iso.utils 
{
	import flash.geom.Point;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author ...
	 */
	public class DrawLines
	{
		
		public var lineColor:Number;
		public var lineThick:Number;
		public var lineAlpha:Number;
		public var fillColor:Number;
		public var fillAlpha:Number;
		private var drawing:BitmapData;
		public function DrawLines(width:Number, height:Number) {
			lineColor = 0xFF000000;
			lineThick = 1;
			lineAlpha = 100;
			fillColor = 0xFFFFFFFF;
			fillAlpha = 100;
			drawing = new BitmapData(width, height, true, fillColor);
		}
		public function drawLine(s:Point, e:Point) {
			s = roundPoint(s);
			e = roundPoint(e);
			var steep = Math.abs(e.y-s.y)>Math.abs(e.x-s.x);
			if (steep) {
				if (s.y>e.y) {
					var temp = s.clone();
					s = e.clone();
					e = temp.clone();
				}
				var dy = (e.y-s.y);
				for (var y = 0; y<=dy; y++) {
					var perc = y/dy;
					var temp = Point.interpolate(s, e, perc);
					temp = roundPoint(temp);
					drawing.setPixel(temp.x, temp.y, lineColor);
				}
			} else {
				if (s.x>e.x) {
					var temp = s.clone();
					s = e.clone();
					e = temp.clone();
				}
				var dx = (e.x-s.x);
				for (var x = 0; x<=dx; x++) {
					var perc = x/dx;
					var temp = Point.interpolate(s, e, perc);
					temp = roundPoint(temp);
					drawing.setPixel(temp.x, temp.y, lineColor);
				}
			}
		}
		public function clear():Void {
			drawing.fillRect(drawing.rectangle, 0xFFFFFFFF);
		}
		private function roundPoint(p:Point):Point {
			p.x = Math.round(p.x);
			p.y = Math.round(p.y);
			return p;
		}
		public function getBitmap():BitmapData {
			return drawing;
		}

			
		}
	}
}