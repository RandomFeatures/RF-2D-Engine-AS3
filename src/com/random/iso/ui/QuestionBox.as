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
	public class QuestionBox extends MessageBox
	{
			
		private var m_onYesCallback:Function = null;
		private var m_onNoCallback:Function = null;
		
		private var m_btnYes:aleButton;
		private var m_btnNo:aleButton;
	
		public function QuestionBox(font:String = null, align:String ="left") 
		{
			super(font, align);

			m_btnYes = new aleButton("");
			m_btnNo = new aleButton("");
		}
		
		public function set NoButton(value:aleButton):void {
			m_btnNo = value;
		}
		public function get NoButton():aleButton {
			return m_btnNo;
		}
		public function set YesButton(value:aleButton):void {
			m_btnYes = value;
		}
		public function get YesButton():aleButton {
			return m_btnYes;
		}
		
		public function showMessage(msg:String, onYesCallback:Function, onNoCallback:Function):void
		{
			super.setMessage(msg);
			m_onYesCallback = onYesCallback;
			m_onNoCallback = onNoCallback;
		}
		
		override public function hide():void {
			super.hide();
			m_onYesCallback = null;
			m_onNoCallback  = null;
		}
		
		override public function render():void {
			//not visible so who cares
			if (!m_Visible) return;
			super.render();
			m_btnYes.render();
			m_btnNo.render();
		}
		
		override public function MouseClick(x:int, y:int):Boolean {
			var rtn:Boolean = false;

			if (m_Visible)
			{
				rtn = true;
				if (m_btnYes.mouseClick(x,y)) {
					//call back
					m_onNoCallback = null;
					fadeAway(0.25);
				}
				if (m_btnNo.mouseClick(x,y)) {
					m_onYesCallback = null;
					fadeAway(0.25);
				}
			}
			return rtn;
		}
		
		override public function MouseMove(x:int, y:int):Boolean
		{
			if (!m_Visible) return false;
			
			if (m_btnYes != null) if (m_btnYes.getMouseOver(x, y)) return true;
			if (m_btnNo != null) if (m_btnNo.getMouseOver(x,y)) return true;
			
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
				m_btnNo.alpha = m_BackGround.alpha;
				m_btnYes.alpha = m_BackGround.alpha;
				if(m_BackGround.alpha <= 0)
				{
					m_BackGround.alpha = 0;
					m_LabelText.alpha = 0;
					m_btnNo.alpha = 0;
					m_btnYes.alpha = 0;
					m_Visible = false;
					m_Fading = false;

					if (m_onYesCallback != null)
					{
						m_onYesCallback();
						m_onYesCallback = null;
					}
					if (m_onNoCallback != null)
					{
						m_onNoCallback();
						m_onNoCallback = null;
					}
				}
				
			}
		}
		
		override  public function setPosition(posx:int, posy:int):void {
			super.setPosition(posx, posy);	
			m_btnYes.setPosition(posx + 120, posy + 160);			
			m_btnNo.setPosition(posx + 120, posy + 160);			
		}
		
		
	}

}