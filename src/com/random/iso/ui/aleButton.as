package com.random.iso.ui 
{
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.flixel.FlxLoadSprite;
	import com.random.game.consts.RealmConsts;
	import com.random.iso.utils.AnimationLoader;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import com.random.iso.ui.ToolTips;
	import org.flixel.FlxG;
	import com.random.game.consts.Globals;

	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class aleButton extends EventDispatcher
	{
		private var m_ImageLoader:AnimationLoader;
		private var m_Highlight:Boolean = false;
		private var m_HightlightColor:uint = 0x008E35EF;
		protected var m_MouseOver:Boolean = false;
		protected var m_Enabled:Boolean;  //Show the sprite;
		protected var m_ScreenX:int; //actual 2d screen cords where the image is being drawn
		protected var m_ScreenY:int;//actual 2d screen cords where the image is being drawn
		protected var m_ButtonImage:FlxLoadSprite = null;;
		protected var m_GlowEffect:GlowFilter = null;
		protected var m_FileName:String;
		protected var m_ToolTipBubble:ToolTips = null;
		private var m_ToolTip:String = null;
		
		
		public function aleButton(img:String) 
		{
			super();
			m_GlowEffect = new GlowFilter(m_HightlightColor);
			if (img != "")
				loadImage(img);
		}
		public function set ToolTip(value:String):void 
		{ 
			if (value != m_ToolTip)
            {
                m_ToolTip = value;
                if (m_ToolTipBubble)
                {
                    m_ToolTipBubble.text = m_ToolTip;
                    m_ToolTipBubble.init();
                    updateToolTip();
                }
            }
            return;
		}
		public function get ToolTip():String { return m_ToolTip; }
		
		public function set alpha(value:Number):void { m_ButtonImage.alpha = value; }
		public function get alpha():Number { return m_ButtonImage.alpha; }
		
		public function destroy():void {
			m_GlowEffect = null;
			m_ImageLoader = null;
			m_ButtonImage.destroy();
			m_ButtonImage = null;
		}
		
		public function setPosition(posx:int, posy:int):void {
			if (m_ButtonImage != null)  
			{
				m_ButtonImage.x = posx;
				m_ButtonImage.y = posy;
				getMouseOver(FlxG.mouse.x, FlxG.mouse.y);
			}
			
			
		}
		
		public function loadImage(url:String):void {
			//Use the AnimationLoader to get the image from the server
			if (url != "")
			{
				m_FileName = url;
				m_ImageLoader = new AnimationLoader();
				m_ImageLoader.addEventListener(AnimationLoader.DONE, onImageDoneLoading);
				m_ImageLoader.loadFile(Globals.RESOURCE_BASE + url, true);
			}
		}

		public function embedImage(img:Class):void {
			m_ButtonImage = new FlxLoadSprite();
			m_ButtonImage.loadGraphic(img, false, false, 0, 0, true);
		}
		//The image has downloaded from the sever
		private function onImageDoneLoading(e:Event):void {
			setButtonImage(m_ImageLoader.SpriteImage, m_FileName);
			m_ImageLoader.removeEventListener(AnimationLoader.DONE, onImageDoneLoading);	
			m_ImageLoader = null;
		}
		
		public function setButtonImage(img:Bitmap, filename:String):void
		{
			m_ButtonImage = new FlxLoadSprite();
			m_ButtonImage.loadExtGraphic(img, filename, true, false, false, 0, 0, true );
		}
		
		//render the art onto the screeen
		public function render():void
		{
			if(m_ButtonImage != null)  m_ButtonImage.render()	
		}
		//update the animation on the screen
		public function update():void
		{
			if(m_ButtonImage != null)  m_ButtonImage.update();	
		}
		
		//something else noticed that the mouse left and notified me
		public function setMouseOut():void 
		{
			if (m_MouseOver)
				onMouseOut();	
			m_MouseOver = false;
		}
		
		//override mouse to not dispatch events
		public function getMouseOver(x:int, y:int):Boolean
		{
			//the art is not loaded to who cares
			if (!m_ButtonImage) return false;
			
			if (!m_MouseOver)
			{//the mouse was not over the image on the last frame
				if (x > m_ButtonImage.x && x < (m_ButtonImage.x + m_ButtonImage.width))
				{//mouse in within the bounding box width
					if (y > m_ButtonImage.y && y < (m_ButtonImage.y + m_ButtonImage.height))
					{//mouse is also in the bounding box heoght
						if (m_ButtonImage.pixels.hitTest(new Point(m_ButtonImage.x, m_ButtonImage.y), 0, new Point(x, y)))
						{//mouse is acutally over non transparent pixels
							m_MouseOver = true;
							onMouseOver();
							if (m_ToolTipBubble == null && (m_ToolTip != null))
							{
								ToolTips.hide();
								m_ToolTipBubble = new ToolTips(this);
								m_ToolTipBubble.text = m_ToolTip;
								m_ToolTipBubble.init()
								m_ToolTipBubble.addToStage();
							}
							else
							{
								ToolTips.hide();
								if (m_ToolTip != null)
									m_ToolTipBubble.addToStage();
							}
							return true;
						}
					}
				}
			}else
			{//mouse was over on the last frame see if it still is
				if (x > m_ButtonImage.x && x < (m_ButtonImage.x +  m_ButtonImage.width))
				{//mouse in within the bounding box width
					if (y > m_ButtonImage.y && y < (m_ButtonImage.y + m_ButtonImage.height))
					{//mouse is also in the bounding box height
						if (m_ButtonImage.pixels.hitTest(new Point(m_ButtonImage.x, m_ButtonImage.y), 0, new Point(x, y)))
						{//mouse is acutally over non transparent pixels
							updateToolTip();
							return true;
						}
					}
				}
				//mouse has left the image
				m_MouseOver = false;
				onMouseOut();
				if (m_ToolTipBubble)
				{
					if (m_ToolTipBubble.parent)
					{
						ToolTips.hide();
						//m_ToolTipBubble.parent.removeChild(m_ToolTipBubble);
						m_ToolTipBubble = null;
					}
				}
				return false;
			}
			//mouse was never here
			return false;
		}
		
		public function updateToolTip() : void
        {
            if (m_ToolTipBubble)
            {
                m_ToolTipBubble.update();
            }
            return;
        }// end function
		
		
		public function mouseClick(x:int, y:int):Boolean {
			var rtn:Boolean = false;
			
			if (x > m_ButtonImage.x && x < (m_ButtonImage.x + m_ButtonImage.width))
			{//mouse in within the bounding box width
				if (y > m_ButtonImage.y && y < (m_ButtonImage.y + m_ButtonImage.height))
				{//mouse is also in the bounding box heoght
					if (m_ButtonImage.pixels.hitTest(new Point(m_ButtonImage.x, m_ButtonImage.y), 0, new Point(x, y)))
					{//mouse is acutally over non transparent pixels
						setMouseOut();
						rtn = true;	
					}
				}
			}
			
			return rtn 
		}
		
		//when the mouse leaves remove the glow effect
		public function onMouseOver():void {
			if (m_GlowEffect != null) {
				m_ButtonImage.SetFilter(m_GlowEffect);
			}
		}
		
		//when the mouse enters add the glow effect
		public function onMouseOut():void {
			removeGlowEffect();
		}
		
		public function addGlowEffect(glow:GlowFilter):void
		{
			m_GlowEffect = glow;
		}
		
		public function removeGlowEffect():void
		{
			m_ButtonImage.RemoveFilter();
			m_ButtonImage.update();
		}
		
	}

}