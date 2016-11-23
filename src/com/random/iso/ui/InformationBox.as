package com.random.iso.ui 
{
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import com.random.iso.ui.aleButton;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class InformationBox extends MessageBox
	{
		
		private var m_onOkCallback:Function = null;
		private var m_Button:aleButton;

		public function InformationBox(font:String = null, align:String ="left") 
		{
			super(font, align);
			m_Button = new aleButton("");
			
		}
		
		public function set Button(value:aleButton):void {
			m_Button = value;
		}
		public function get Button():aleButton {
			return m_Button;
		}

		override public function render():void {
			//not visible so who cares
			if (!m_Visible) return;
			super.render();
			m_Button.render();
		}
		
		public function showMessage(msg:String, onOkCallback:Function):void {
			
			super.setMessage(msg);
			m_onOkCallback = onOkCallback;
		}
		
		override public function MouseClick(x:int, y:int):Boolean {
			var rtn:Boolean = false;
			
			if (m_Visible)
			{
				rtn = true;
				if (m_Button.mouseClick(x,y)) {
					fadeAway(0.25);
				}
			}
			return rtn;
		}
		
		
		override public function MouseMove(x:int, y:int):Boolean
		{
			if (!m_Visible) return false;
			
			if (m_Button != null) if (m_Button.getMouseOver(x,y)) return true;
			
			if (m_Visible) return true;
			
			return false
		}

		//update the image fading away
		override public function fading():void
		{
			if (m_Fading)
			{
				m_BackGround.alpha -= FlxG.elapsed / m_Delay;;
				m_LabelText.alpha = m_BackGround.alpha;
				m_Button.alpha = m_BackGround.alpha;
				if(m_BackGround.alpha <= 0)
				{
					m_BackGround.alpha = 0;
					m_Button.alpha = 0;
					m_LabelText.alpha = 0;
					m_Fading = false;
					
					if (m_onOkCallback != null)
					{//call back the close
						m_onOkCallback();
						m_Visible = false;
						m_onOkCallback = null;
					}
					
				}
				
			}
		}
		
		override public function setPosition(posx:int, posy:int):void {
			
			super.setPosition(posx, posy);
			m_Button.setPosition(posx + 120, posy + 160);			
		}
		
		
		
		
	}

}