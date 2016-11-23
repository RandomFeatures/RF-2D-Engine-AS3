package com.random.iso.ui 
{
	
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	import flash.utils.setTimeout;
		
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class BubbleText
	{
		
		  
		protected var m_LabelText:FlxText;
		protected var m_Visible:Boolean = false;
		protected var m_Fading:Boolean;
		private var m_Delay:Number;
		
		public function BubbleText(label:String = "system", font:String = null, size:Number = 200, align:String ="left", color:uint = 0x00000000) 
		{
			m_LabelText = new FlxText(100, 100, size, label);
			m_LabelText.setFormat(font, 16, color, align, 0x000000);
            return;
		}
		
		public function get X():int {
			return m_LabelText.x;
		}
		public function get Y():int {
			return m_LabelText.y;
		}
		public function Visible():Boolean
		{
			return m_Visible;
		}
        public function setPosition(posx:int, posy:int):void {
			m_LabelText.x = posx;
			m_LabelText.y = posy;
			m_LabelText.update();
		}
		
		public function get LabelText():FlxText
        {
            return m_LabelText
        }

		public function showText(lable:String, color:uint = 0x00000000):void
		{
			m_LabelText.text = lable;
			m_LabelText.color = color;
			m_Visible = true;
			setTimeout(fadeAway, 500);
		}
		
		private function fadeAway():void
		{
			m_Delay = 5;
			m_LabelText.alpha = 1;
			m_Fading = true;
		}
		
		public function render():void
		{
			//render the image on the screen
			if(m_Visible)
				m_LabelText.render();
		}
		
		//update the image animation
		public function update():void
		{
			if (m_Fading)
			{
				m_LabelText.alpha -= FlxG.elapsed/m_Delay;
				if(m_LabelText.alpha <= 0)
				{
					m_LabelText.alpha = 0;
					m_Visible = false;
				}
				m_LabelText.y -= .5;
			}
		}
	}

}