package com.random.iso.ui 
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
    import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.geom.Point;
    import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import org.flixel.FlxG;
	import com.random.iso.consts.GameConstants;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class ToolTips extends Sprite
	{
		private var m_TextField:TextField;
        private var m_Text:String;
        public var m_Font:String = "system";
        private var m_textFormat:TextFormat;
        private var m_padding:int = 5;
        public static var isDisabled:Boolean = false;
        public static var referenceObject:Object;
		
		
		public function ToolTips(ref:Object = null) 
		{
			referenceObject = ref;
            m_TextField = new TextField();
            m_textFormat = new TextFormat("system", 15, 0, false);
		}
		
		
		public function set text(txt:String):void
        {
            this.m_Text = txt;
            this.m_TextField.htmlText = txt;
        }// end function

        public function set Padding(value:int):void
        {
            m_padding = value;
        }// end function

        public function addToStage():void
        {
           this.update();
           FlxG.state.parent.stage.addChildAt(this, FlxG.state.parent.stage.numChildren);
        }// end function

        private function setupTextField():void
        {
            m_TextField.multiline = true;
            m_TextField.wordWrap = true;
            m_TextField.width = 255;
            m_TextField.autoSize = TextFieldAutoSize.LEFT;
            m_TextField.cacheAsBitmap = true;
            m_TextField.embedFonts = true;
            m_TextField.defaultTextFormat = m_textFormat;
            m_TextField.setTextFormat(m_textFormat);
        }// end function

        public function init():void
        {
			var bgHeight:Number = 0
			var bgWidth:Number = 0;
			var bgImageData:BitmapData;
			var bgImage:Bitmap;
			var bgMatrix:Matrix;
			var bgRotation:Number;
			var bgColors:Array = [16777215, 14611711, 5075864];
		    var bgAlpha:Array = [1, 1, 1];
            var bgRatio:Array = [0, 10, 245];
			
			if (ToolTips.isDisabled == true)
            {
                ToolTips.hide();
                return;
            }
            this.graphics.clear();
            while (this.numChildren > 0)
            {
                this.removeChildAt(0);
            }
            if (this.m_Text == "") return;
            
            setupTextField();
            
            bgHeight = Math.max(m_TextField.textHeight, 0) + m_padding * 2;
            bgWidth = m_TextField.textWidth + m_padding * 2;
            bgImageData = new BitmapData(bgWidth, bgHeight, true, 0);
            
			bgImageData.draw(m_TextField);
            bgImage = new Bitmap(bgImageData);
            bgMatrix = new Matrix();
            bgRotation = 90 * Math.PI / 180;
            bgMatrix.createGradientBox(bgWidth, bgHeight, bgRotation, 0, 0);

            this.addChild(bgImage);
			
            
            this.graphics.beginGradientFill(GradientType.LINEAR, bgColors, bgAlpha, bgRatio, bgMatrix);
            this.graphics.lineStyle(1);
            this.graphics.drawRoundRect((-m_padding) / 2, (-m_padding) / 2, bgWidth, bgHeight, 8, 8);
            this.graphics.endFill();
            this.name = "FancyToolTip";
        }// end function
		
		
		
        public function update():void
        {
			var StartPos:Point;
			 
            if (ToolTips.isDisabled == true)
            {
                ToolTips.hide();
                return;
            }
            var offSetX:Number = 10;
            var offSetY:Number = 50;
            if (ToolTips.getActiveToolTip())
            {
                offSetY = ToolTips.getActiveToolTip().height;
            }
            StartPos = new Point(FlxG.mouse.x + offSetX, FlxG.mouse.y - offSetY);
            if (GameConstants.SCREENWIDTH - this.width < StartPos.x)
            {
                StartPos.x = FlxG.mouse.x - this.width - 10;
            }
            if (this.height > StartPos.y)
            {
                StartPos.y =FlxG.mouse.y + 10;
            }
            if (StartPos.y + this.height >= GameConstants.SCREENHEIGHT)
            {
                StartPos.y = GameConstants.SCREENHEIGHT - (this.height + 1);
            }
            this.x = StartPos.x;
            this.y = StartPos.y;
        }// end function

        public function get text():String
        {
            return this.m_Text;
        }// end function

        public static function getActiveToolTip():DisplayObject
        {
            var FancyToolTip:DisplayObject = null;
            if (FlxG.state.parent.stage.getChildByName("FancyToolTip"))
            {
                FancyToolTip = FlxG.state.parent.stage.getChildByName("FancyToolTip");
            }
            return FancyToolTip;
        }// end function

        public static function hide():void
        {
            if (FlxG.state.parent.stage.getChildByName("FancyToolTip"))
            {
                FlxG.state.parent.stage.removeChild(FlxG.state.parent.stage.getChildByName("FancyToolTip"));
            }
            if (FlxG.state.parent.stage.getChildByName("FancyToolTip"))
            {
                FlxG.state.parent.stage.removeChild(FlxG.state.parent.stage.getChildByName("FancyToolTip"));
            }

        }// end function

    }

}