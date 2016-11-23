package com.random.iso.ui 
{
	import com.random.iso.events.MenuEvent;
	import com.random.iso.ui.ContextMenuItem;
	import flash.events.*;
	import org.flixel.FlxSprite;
	import flash.geom.Point;
	import com.random.iso.consts.GameConstants;
	import org.flixel.FlxSound;
	/**
	 * control and display menu items
	 * ...
	 * @author Allen Halsted
	 */
	public class ContextMenu extends EventDispatcher
	{
		
		        
        /**
         * @private
         * Menu item background
         */
        [Embed(source='/assets/WhiteBox.png')]
        private static var MenuItemBG:Class;
		
		
        private var m_x:int;
		private var m_y:int;
		private var m_Width:int;
		private var m_Height:int;
		private var m_BackGround:FlxSprite;
		private var m_BackGroundColor:uint;
		private var m_MenuTextColor:uint;
		private var m_MenuTextHoverColor:uint;
		private var m_MenuHoverColor:uint;
		private var m_MouseIndx:int;
		private var m_MouseOver:Boolean;
		private var m_CurrentSelected:Object;
        private var m_MenuItemsList:Array;
		private var m_Visible:Boolean = false;
        public static var m_currentMenu:ContextMenu;
		private var m_SfxMouseOver:FlxSound;
		
        public function ContextMenu(itemlist:Array, bgColor:uint, txtColor:uint, txtHoverColor:uint, bgHoverColor:uint)
        {
           
			m_BackGround = new FlxSprite(0, 0);
			m_BackGround.loadGraphic(MenuItemBG, false, false, 100, 20, false);
			m_BackGroundColor = bgColor;
			m_MenuTextColor = txtColor;
			m_MenuTextHoverColor = txtHoverColor;
			m_MenuHoverColor = bgHoverColor;
			m_MouseIndx = 0;
			m_Height = (m_BackGround.height -1)* (itemlist.length+1);
			m_Width = m_BackGround.width;
			
            m_MenuItemsList = [];
            
			for each (var mnuitem:ContextMenuItem in itemlist)
			{
				m_MenuItemsList.push(mnuitem);
			}
			m_SfxMouseOver = new FlxSound();
			m_SfxMouseOver.loadEmbedded(menu_mouseover, false);
			
        }
		
		public function get X():int { return m_x; }
		public function get Y():int { return m_y; }
		public function set CurrentSelected(value:Object):void {
			m_CurrentSelected = value;
		}
		public function get CurrentSelected():Object {
			return m_CurrentSelected;
		}
		public function get Visible():Boolean { return m_Visible; }
		
		public function setPosition(posx:int, posy:int):void {
			var StartPos:Point;
			 
            var offSetX:Number = 10;
            var offSetY:Number = 50;

			offSetY = 0;// m_Height;
            
            StartPos = new Point(posx + offSetX, posy - offSetY);
            if (GameConstants.SCREENWIDTH - m_Width < StartPos.x)
            {
                StartPos.x = posx - m_Width - 10;
            }
            if (m_Height > StartPos.y)
            {
                StartPos.y = posy + 10;
            }
            if (StartPos.y + m_Height >= (GameConstants.SCREENHEIGHT - 125))
            {
                StartPos.y = (GameConstants.SCREENHEIGHT - 125) - (m_Height + 1);
            }

            m_x = StartPos.x;
            m_y = StartPos.y -20;
			
			var indx:int = 0;
		
			
			for each (var mnuitem:ContextMenuItem in m_MenuItemsList)
			{
				indx++;
				mnuitem.setPosition(m_x+3, (m_y + ((m_BackGround.height -1) * indx)));
			}

		}
		
		public function cleanup():void {
			m_BackGround.kill();
			m_BackGround = null;	
		}
		
		public function reInit():void {
			cleanup();
			m_BackGround = new FlxSprite(0, 0);
			m_BackGround.loadGraphic(MenuItemBG, false, false, 100, 20, false);
		}
		
		
		public function render(): void
		{
			//not visible so who cares
			if (!m_Visible) return;
			//render each item of the menu
			var indx:int = 0;
			for each (var mnuitem:ContextMenuItem in m_MenuItemsList)
			{
				indx++;
				m_BackGround.x = m_x;
				m_BackGround.y = m_y + ((m_BackGround.height -1) * indx);
				//draw with highlight color?
				m_BackGround.color = (indx != m_MouseIndx) ? m_BackGroundColor : m_MenuHoverColor; 
				m_BackGround.render();
				mnuitem.LabelText.color = (indx != m_MouseIndx) ? m_MenuTextColor : m_MenuTextHoverColor; 
				mnuitem.render();

			}
			
		}
		
		//hide the menu from the user
        public function hide() : void
        {
			m_Visible = false;
			m_CurrentSelected = null;
        }

		//override mouse to not dispatch events
		public function MouseOver(x:int, y:int):Boolean
		{
			//not visible so who cares
			if (!m_Visible) return false;
			
			if (!m_MouseOver)
			{//mouse was not over the menu last frame
				if (x > m_x && x < (m_x + m_Width))
				{//moouse in within the bonding box width
					if (y > m_y && y < (m_y + m_Height))
					{//mouse in in the bounding box height
						//for certian inside the menu...now which one
						m_MouseIndx = (y - m_y) / (m_BackGround.height -1);
						m_MouseOver = true;
						//m_SfxMouseOver.play();
						return true;
					}
				}
			}else
			{//mouse whas here last frame see if it still is
				if (x > m_x && x < (m_x + m_Width))
				{//mouse is in the bounding width
					if (y > m_y && y < (m_y + m_Height))
					{//mouse is in the bounding height
						//track the mouse moving inside the menu
						m_MouseIndx = (y - m_y) / (m_BackGround.height -1);
						m_MouseOver = true;
						return true;
					}
				}
				//mouse has left the menu
				m_MouseOver = false;
				m_MouseIndx = 0;
				return false;
			}
			//mouse was never here
			return false;
		}
		
	
		public function MouseClick(x:int, y:int):Boolean { 
			
			var mnuEvent:MenuEvent;
			var mnuItem:ContextMenuItem;
			//if menu not visible or nothing is selectend then who cares
			if (!m_Visible) return false;
			if (m_CurrentSelected == null) return false;
			
			if (m_MouseOver)
			{//was here last frame but make sure the click is acutally inside
				if (x > m_x && x < (m_x + m_Width))
				{//click was inside the bounding box width
					if (y > m_y && y < (m_y + m_Height))
					{//click was inside the bounding box height
						//for certian inside the menu...now which one
						m_MouseIndx = (y - m_y) / (m_BackGround.height -1);
						//throw an event back to the menu manager that an item was clicked
						mnuItem = m_MenuItemsList[m_MouseIndx - 1];
						if (mnuItem != null)
						{
							mnuEvent = new MenuEvent( MenuEvent.ITEM_CLICKED );
							mnuEvent.CurrentSelected = m_CurrentSelected;
							mnuEvent.Action = mnuItem.Action;
							dispatchEvent(mnuEvent);
						}
						hide();
						return true;
					}
				}
			}
			//nothing to see here... move along
			return false;
		}
		
		//show the mouse at the cursor over the currently select object
        public function show(posX:Number, posY:Number, item:Object) : void
        {
            m_CurrentSelected = item;
			setPosition(posX, posY);
			m_Visible = true;
        }


		
	}

}