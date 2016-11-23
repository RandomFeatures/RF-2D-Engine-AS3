package com.random.iso
{
	import com.random.iso.consts.*
	import com.random.iso.consts.GameConstants;
	import com.random.iso.map.IsoMap;
	import com.random.iso.ISortable;
	import com.random.iso.ui.ToolTips;
	import com.random.iso.utils.IsoPoint;
	import com.random.iso.utils.IsoUtil;
	import com.random.iso.map.tile.Tile;
	import com.random.iso.utils.NumberUtil;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import org.flixel.FlxG;
	import com.random.iso.utils.GUID;
	import flash.filters.GlowFilter;
	

	/**
	 * Base class for all game objects to inherit from
	 * ...
	 * @author Allen Halsted
	 */
	public class GameObject extends EventDispatcher implements ISortable 
	{
		//controls the objects location relitive to the positon of the screen
		protected static var m_ScreenXOffset:int;
		protected static var m_ScreenYOffset:int;
		
		protected var m_MouseOver:Boolean = false;
		protected var m_Enabled:Boolean = true;  //Show the sprite;
		protected var m_Blended:Boolean; //Blend the Sprite
		protected var m_Locked:Boolean;  // Specific action lock
		protected var m_OnScreen:Boolean; //determin if the object is currenly on the screen
		protected var m_Selected:Boolean; //determin if the object
		protected var m_UseShadows:Boolean; //should the engine draw a shadow for this object
		protected var m_Type:String; //object type: static, sprinte, monsters, player, etc
		protected var m_PosX:int;
		protected var m_PosY:int;
		protected var m_xOffset:int; //pixel offset to line the image up correctly on the tile
		protected var m_yOffset:int;//pixel offset to line the image up correctly on the tile
		protected var m_Rows:int; //how many rows the object takes up
		protected var m_Cols:int; // how many cols the object takes up
		protected var m_Frame:int; //current frame
		protected var m_OwnerItemID:String; //ID from TblPlayer_Room_Items
		protected var m_ScreenX:int; //actual 2d screen cords where the image is being drawn
		protected var m_ScreenY:int;//actual 2d screen cords where the image is being drawn
		protected var m_Width:int; //width of the image bounding box
		protected var m_Height:int; //height of the image bounding box
		//protected var m_GUID:String; //Global id for the object
		protected var m_DisplayName:String; //objects dispaly name
		protected var m_EditMode:Boolean = false;
		//width of tile in 3D
		protected var m_TileWidth:Number;
		//height of tile in 3D
		protected var m_TileHeight:Number;
		
		//Object Collison properties
		private var m_Movable:Boolean = false;
		protected var m_Walkable:Boolean = false;
		protected var m_Overlap:Boolean = false;
		protected var m_Loaded:Boolean = false;
		//Isometric Utility
		protected var m_IsoUtil:IsoUtil;
		//list of all tiles that this object occupies
		protected var m_TilesList:Array;
		//world layer to be rendered in
		protected var m_Layer:int;
		//threat radious for monsters and traps
		protected var m_ThreatRows:int = 0;
		protected var m_ThreatCols:int = 0;

		protected var m_CurrentDirection:String = "SW";
		protected var m_Game:GameObjectManager;
		
		protected var m_FacingCount: int;
		protected var m_NewItem:Boolean = false;
		protected var m_InvItem:Boolean = false;
		protected var m_NewItemGlowEffect:GlowFilter;
		protected var m_ToolTipBubble:ToolTips = null;

		//UI Protperties
		protected var m_ObjectID:int;
		protected var m_ItemName:String;
		protected var m_ToolTip:String;
		protected var m_BuckCost:int;
		protected var m_CoinCost:int;
		protected var m_IconFile:String;
		protected var m_ObjectType:int;
		private var m_onStopEvent:String;
		private var m_onClickEvent:String;

		public function GameObject() 
		{
			m_Type = ObjTypes.OBJ;
			m_Blended = false;
			m_Locked = false;
			m_UseShadows = true;
			m_Frame = -1;
			m_PosX = 0;
			m_PosY = 0;
			m_xOffset = 0;
			m_yOffset = 0;
			m_Rows = 1;
			m_Cols = 1;
			m_ScreenX = 0;
			m_ScreenY = 0;
			m_IsoUtil = new IsoUtil();
			m_FacingCount = 0;
			//m_GUID = GUID.create();
			
			//figure out the width of the tile in 3D space
			m_TileWidth = m_IsoUtil.mapToIsoWorld(GameConstants.TILEWIDTH, 0).X;
			
			//the tile is a square in 3D space so the height matches the width
			m_TileHeight = m_TileWidth;
			m_TilesList = [];
			
		}
		
		//Properties for the gameobject
		public function get DisplayName():String { return m_DisplayName; }	//Sprites Display Name
		//public function get getGUID():String { return m_GUID; }		//This sprites GUID
		public function get xPos():int { return m_PosX; }			//World X
		public function get yPos():int { return m_PosY; }			//World Y
		public function get xOffset():int { return m_xOffset; }		//Sprite offset from wrold x
		public function get yOffset():int { return m_yOffset; }		//Sprite offset from world y
		public function get ScreenX():int { return m_ScreenX; }		//Actual Screen X
		public function get ScreenY():int { return m_ScreenY; }		//Actual Screen Y
		public function get Rows():int { return m_Rows; }	//How many tiles long
		public function get Cols():int { return m_Cols; }		//How many tiles wide
		public function get Frame():int { return m_Frame; }			//Get the current animation frame
		public function get OwnerItemId():String { return m_OwnerItemID;	 }		 //ID from TblPlayer_Room_Items
		public function get OnScreen():Boolean { return m_OnScreen;	 }	//see if this sprite is on the screen
		public function get Enabled():Boolean { return m_Enabled; }		//See if this sprite is visible
		public function get Blended():Boolean { return m_Blended; }		//See if this sprite is blended
		public function get Locked():Boolean { return m_Locked; }		//Specific action lock
		public function get Selected():Boolean { return m_Selected; }		//See if this sprite is selected
		public function get Walkable():Boolean { return m_Walkable; }
		public function get Overlap():Boolean { return m_Overlap; }
		public function get TilesList():Array { return m_TilesList; }
		public function get Layer():int { return m_Layer; }
		public function get EditMode():Boolean { return m_EditMode; }
		public function get Dir():String { return m_CurrentDirection; }
		public function get ThreatRows():int { return m_ThreatRows; }	//How many tiles long
		public function get ThreatCols():int { return m_ThreatCols; }		//How many tiles wide
		public function get FacingCount():int { return m_FacingCount; }
		public function get NewItem():Boolean { return m_NewItem; }
		public function get InvItem():Boolean { return m_InvItem; }

		public function get Loaded():Boolean { return m_Loaded; }
		
		//UI properties
		public function get ObjectID():int { return m_ObjectID };//objectID for this object based objectType
		public function get ItemName():String { return m_ItemName };
		public function get ToolTip():String { return m_ToolTip };
		public function get BuckCost():int { return m_BuckCost };
		public function get CoinCost():int { return m_CoinCost };
		public function get IconFile():String { return m_IconFile };
		public function get ObjectType():int { return m_ObjectType };
		
		
		public function get onStopEvent():String { return m_onStopEvent; }
		public function get onClickEvent():String { return m_onClickEvent; }

		
		public function set DisplayName(value:String):void { m_DisplayName = value; }	//Sprites Display Name
		//public function set getGUID(value:String):void  { m_GUID = value; }		//This sprites GUID
		public function set xPos(value:int):void  { m_PosX = value; }			//World X
		public function set yPos(value:int):void  { m_PosY = value; }			//World Y
		public function set xOffset(value:int):void  { m_xOffset = value; }		//Sprite offset from wrold x
		public function set yOffset(value:int):void  { m_yOffset = value; }		//Sprite offset from world y
		public function set ScreenX(value:int):void { m_ScreenX = value; }		//Actual Screen X
		public function set ScreenY(value:int):void{ m_ScreenY = value; }		//Actual Screen Y
		public function set Rows(value:int):void  { m_Rows = value; }	//How many tiles long
		public function set Cols(value:int):void  { m_Cols = value; }		//How many tiles wide
		public function set Frame(value:int):void  { m_Frame = value; }			//Get the current animation frame
		public function set OwnerItemId(value:String):void  { m_OwnerItemID = value;	 }		//Get this sprites ID
		public function set OnScreen(value:Boolean):void  { m_OnScreen = value;	 }	//see if this sprite is on the screen
		public function set Enabled(value:Boolean):void  { m_Enabled = value; }		//See if this sprite is visible
		public function set Blended(value:Boolean):void  { m_Blended = value; }		//See if this sprite is blended
		public function set Locked(value:Boolean):void  { m_Locked = value; }		//Specific action lock
		public function set Selected(value:Boolean):void  { m_Selected = value; }		//See if this sprite is selected
		public function set Walkable(value:Boolean):void { m_Walkable = value; }
		public function set Overlap(value:Boolean):void { m_Overlap = value; }
		public function set Layer(value:int):void { m_Layer = value; }
		public function set EditMode(value:Boolean):void { m_EditMode = value; }
		public function set NewItem(value:Boolean):void { m_NewItem = value; }
		public function set InvItem(value:Boolean):void { m_InvItem = value; }
		
		//UI properties
		public function set ObjectID(value:int):void  { m_ObjectID = value;  };
		public function set ItemName(value:String):void  { m_ItemName = value; };
		public function set BuckCost(value:int):void  { m_BuckCost = value; };
		public function set CoinCost(value:int):void  { m_CoinCost = value; };
		public function set IconFile(value:String):void  { m_IconFile = value; };
		public function set ObjectType(value:int):void  { m_ObjectType = value; };
		
		public function set ThreatRows(value:int):void  { m_ThreatRows = value; }	//How many tiles long
		public function set ThreatCols(value:int):void  { m_ThreatCols = value; }	//How many tiles wide
		
		public function isToolTipVisible() : Boolean
        {
            return m_ToolTipBubble != null;
        }// end function

		public function updateToolTip() : void
        {
            if (m_ToolTipBubble)
            {
                m_ToolTipBubble.update();
            }
            return;
        }// end function
		
		public function set ToolTip(value:String) : void
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
        }// end functio
		
		//the offset of the screen over the game world
		public static function setScreenOffset(xoffset:int, yoffset:int):void
		{
			m_ScreenXOffset = xoffset;
			m_ScreenYOffset = yoffset;
		}
		
		virtual public function cleanUp():void 
		{
			
		}
		
		virtual public function setDir(dir:String):void
		{
			m_CurrentDirection = dir;
		}
		
		public function getTilesList():Array { return m_TilesList; } 
		
		public function getEditorData(xml:XML):void
		{
			
			if (m_EditMode)
			{
				m_ObjectID = int(xml.property.@id);
				m_ItemName = xml.property.@itemname;
				m_ObjectType = int(xml.property.@type);
				m_ToolTip = xml.property.@tooltip;
				m_IconFile = xml.property.@iconfile;
				m_CoinCost = int(xml.property.@coincost);
				m_BuckCost = int(xml.property.@buckcost);
				ToolTip = m_ToolTip +": Left click to edit, move, or sell this item.";
			}
		}
		
		//build a list of tiles that this object touches
		public function addTile(t:Tile):void {
			//trace(m_TilesList.length);
			m_TilesList.push(t);
		}
		
		//remove tiles from the touch list
		public function removeTile(t:Tile):void {
			for (var i:int = 0; i < m_TilesList.length;++i) {
				if (m_TilesList[i] == t) {
					m_TilesList.splice(i, 1);
					break;
				}
			}
		}

		public function clearTileList():void {
			for (var i:int = 0; i < m_TilesList.length;++i) {
					m_TilesList.splice(i, 1);
			}
			m_TilesList = [];
		}
		
		
		public function faceTarget(x:int, y:int):void
		{
			
			var ang_rad:Number = Math.atan2(m_PosX -x, m_PosY-y);
			
			var Angle:Number = ang_rad * 180 / Math.PI;
			var AngleIndex:int = NumberUtil.findAngleIndex(Angle, 45);

			switch (AngleIndex)
			{
				case 0:
					setDir(IsoConstants.DIR_NE)
					break;
				case 2:
					setDir(IsoConstants.DIR_NW)
					break;
				case 4:
					setDir(IsoConstants.DIR_SW)
					break;
				case 6:
					setDir(IsoConstants.DIR_SE)
					break;
			}
		}
	
		//figure out the objects 2d screen pos based on the tile it cupies
		virtual public function setPosition(posX:int, posY:int):void
		{
			m_PosY = posY;
			m_PosX = posX;
			
			//find 3D coordinates
			var iso_x:Number = m_PosX * m_TileWidth;
			var iso_z:Number = -m_PosY * m_TileHeight;
			
			//map 3D coordinates to the screen
			var screenCoord:IsoPoint = m_IsoUtil.mapToScreen(iso_x, 0, iso_z);
			
			//update display object with screen coordinates
			m_ScreenX = screenCoord.X - m_ScreenXOffset;
			m_ScreenY = screenCoord.Y - m_ScreenYOffset;
			
			//trace("x:" + m_ScreenX + " y:" + m_ScreenY);
		}
		
		//determin of the mouse is over the object and if so fire and event
		virtual public function getMouseOver(x:int, y:int):Boolean
		{
			if (!m_MouseOver)
			{//mouse wasnt here before but might be now
				if (x > m_ScreenX && x < (m_ScreenX + m_Width))
				{
					if (y > m_ScreenY && y < (m_ScreenY + m_Height))
					{//mouse is here to so fire an event
						m_MouseOver = true;
						dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
						return true;
					}
				}
			}else
			{//mouse was here see if it still is
				if (x > m_ScreenX && x < (m_ScreenX + m_Width))
				{
					if (y > m_ScreenY && y < (m_ScreenY + m_Height))
					{//mouse is still here so dont fire the event again
						return true;
					}
				}
				//moue not here now so fire the out event
				m_MouseOver = false;
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));		
				return false;
			}
			//never here
			return false;
		}
		
		//something else noticed that the mouse left and notified me
		virtual public function setMouseOut():void 
		{
			if (m_MouseOver)
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));		
			m_MouseOver = false;
		}
		//fire on mouse click
		virtual public function onMouseClick(x:int, y:int):void { 
		
		}
		//fire on mouse over
		virtual public function onMouseOver():void {
			
		}
		//fire on mouse out
		virtual public function onMouseOut():void {
			
		}
		//called by the gameobjectmanager to update status
		virtual public function update():void
		{
			
		}
		//called by the gameobjectmanager to render the object		
		virtual public function render():void
		{

		}

		virtual public function toXML():String 
		{
			return "";
		}
		virtual public function addGlowEffect(glow:GlowFilter):void { }
		
		virtual public function removeGlowEffect():void { }
	}

}