package com.random.iso.ui 
{
	
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	/**
	 * Single menu item for the popup menus
	 * ...
	 * @author Allen Halsted
	 */
	public class ContextMenuItem 
	{
	    
		protected var m_LabelText:FlxText;
        protected var m_Action:String;

        public function ContextMenuItem(label:String, action:String, font:String = null, size:Number = 100, align:String ="left")
        {
            m_LabelText = new FlxText(100, 100, size, label);
			m_LabelText.alignment = align
			m_LabelText.font = font;
			m_LabelText.size = 16;
			m_Action = action;
            return;
        }
		
		
		public function get X():int {
			return m_LabelText.x;
		}
		public function get Y():int {
			return m_LabelText.y;
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

        public function get Action():String
        {
            return m_Action;
        }

		public function render():void
		{
			m_LabelText.render();
		}
		
	}

}