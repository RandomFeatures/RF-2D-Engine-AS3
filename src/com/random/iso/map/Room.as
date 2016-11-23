package com.random.iso.map 
{
	
	import com.random.iso.utils.IsoUtil;
	import com.random.iso.utils.IsoPoint;
	import com.random.game.consts.RealmConsts;
	import com.random.iso.utils.AnimationLoader;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import org.flixel.FlxLoadSprite;
	import flash.geom.Point;
	import com.random.iso.utils.GUID;
	import com.random.game.consts.Globals
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class Room
	{
		private var m_OffsetX:int;
		private var m_OffsetY:int;
		private var m_Cols:int;
		private var m_Rows:int;
		private var m_RoomID:String;
		private var m_Floor:int = 1;
		private var m_Template:int;
		private var m_ObjectID:int;
		private var m_Data:XML;
		private var m_GridX:int = 0;
		private var m_GridY:int = 0;
		private var m_RealmID:int = 0;
		private var m_RealmLevel:int = 0;
		protected var m_ScreenX:int; //actual 2d screen cords where the image is being drawn
		protected var m_ScreenY:int;//actual 2d screen cords where the image is being drawn
		//controls the objects location relitive to the positon of the screen
		protected var m_ScreenXOffset:int;
		protected var m_ScreenYOffset:int;
		//width of tile in 3D
		protected var m_TileWidth:Number;
		//height of tile in 3D
		private var m_TileHeight:Number;
		
		private var m_EmptySpawn:Boolean = false;
		
		//Isometric utilties
		private var m_IsoUtil:IsoUtil;
		protected var m_DeadMonsterList:Array = [];
		protected var m_StaticImage:FlxLoadSprite = null;
		protected var m_AnimationLoader:AnimationLoader;
		protected var m_GlowEffect:GlowFilter = null;
		protected var m_SelectEffect:GlowFilter = null;
		
		private var m_ApplyGlow:Boolean = false;
		private var m_xOffset:int = -64;
		private var m_yOffset:int = 0;
		private var m_Loaded:Boolean = false;
		private var m_Blocked:Boolean = true;
		
		private var m_SEDoor:int = 0;
		private var m_SWDoor:int = 0;
		private var m_NEDoor:int = 0;
		private var m_NWDoor:int = 0;
		private var m_DoorCount:int = 0;
		private var m_ObjectCount:int = 0;
		private var m_FileName:String;
		public function Room(Template:int, realmlevel:int) 
		{
			m_IsoUtil = new IsoUtil();
			//figure out the width of the tile in 3D space
			m_TileWidth = m_IsoUtil.mapToIsoWorld(RealmConsts.D_TILEWIDTH, 0).X;
			m_RealmLevel = realmlevel;
			m_ScreenXOffset = RealmConsts.D_SCREENXOFFSET;
			m_ScreenYOffset = RealmConsts.D_SCREENYOFFSET;
			
			m_Template = Template;
			//the tile is a square in 3D space so the height matches the width
			m_TileHeight = m_TileWidth;
			
			m_GlowEffect = new GlowFilter(0x00FDD017);
			m_SelectEffect = new GlowFilter(0x00009900);
			
			m_RoomID = GUID.create()
		}
		
		public function addDeadMonster(monsterid:String):void
		{
			m_DeadMonsterList.push(monsterid);
		}
		
		public function getDeadMonster(monsterid:String):Boolean 
		{
			var rtn:Boolean = false;
			for each (var id:String in m_DeadMonsterList)
			{
				if (id  == monsterid) 
				{
					rtn = true;
					break;
				}
			}	
			return rtn;
		}
		
		public function set EmptySpawn(value:Boolean):void { m_EmptySpawn = value; }
		public function get EmptySpawn():Boolean { return m_EmptySpawn; }
		
		
		public function LoadMapImage():void {
			
			m_FileName = "";
			m_StaticImage = new FlxLoadSprite();
			m_StaticImage.x = m_ScreenX + m_xOffset;
			m_StaticImage.y = m_ScreenY + m_yOffset;
			
			switch (m_Template)
			{
				case 1:
					m_FileName = "/assets/ui/elements/overhead/12x12.png";
					break;
				case 2:
					m_FileName = "/assets/ui/elements/overhead/8x8.png";
					break;
				case 3:
					m_FileName = "/assets/ui/elements/overhead/10x10.png";
					break;
				case 4:
					m_FileName = "/assets/ui/elements/overhead/5x12.png";
					break;
				case 5:
					m_FileName = "/assets/ui/elements/overhead/12x5.png";
					break;
				case 6:
					m_FileName = "/assets/ui/elements/overhead/5x6.png";
					break;
				case 7:
					m_FileName = "/assets/ui/elements/overhead/6x5.png";
					break;
			}
			if (m_FileName != "")
			{
				m_AnimationLoader = new AnimationLoader();
				m_AnimationLoader.addEventListener(AnimationLoader.DONE, onImageDoneLoading);
				m_AnimationLoader.loadFile(Globals.RESOURCE_BASE+m_FileName, true);
			}
		}
		
		
		//The image has downloaded from the sever
		private function onImageDoneLoading(e:Event):void {
			m_StaticImage.loadExtGraphic(m_AnimationLoader.SpriteImage, m_FileName, true, false, false, 0, 0, m_AnimationLoader.Unique);
			if (m_ApplyGlow) addGlowEffect();
			
			m_AnimationLoader.removeEventListener(AnimationLoader.DONE, onImageDoneLoading);	
			m_AnimationLoader = null;
		}
		
		/**
		 * Returns a tile based on screen coordinates. Null is returned if the position is invalid.
		 * @param	screen x coordinate
		 * @param	screen y coordinate
		 * @return	the tile found at those coordinates, or null
		 */
		public function getTileFromScreenCoordinates(tx:int, ty:int):Point {
			var coord:IsoPoint = m_IsoUtil.mapToIsoWorld(tx+m_ScreenXOffset, ty+m_ScreenYOffset);
			var col:int = Math.floor(coord.X / m_TileWidth);
			var row:int = Math.floor( -coord.Z / m_TileHeight);
			
			return new Point(col, row);
		}
		
		
		
		//render the art onto the screeen
		public function render():void
		{
			if (m_StaticImage != null) m_StaticImage.render();
		}
		//update the animation on the screen
		public function update():void
		{
			if (m_StaticImage != null) m_StaticImage.update();	
		}
		
		public function setBlocked():void {
			if (m_StaticImage != null) m_StaticImage.color = 0x00800517;
			m_Blocked = true;
			
		}
		
		public function setClear():void {
			if (m_StaticImage != null) m_StaticImage.color = 0x00FFFFFF;
			m_Blocked = false;
			
		}
		
		public function LoadFromXML(xml:XML):void
		{
			m_OffsetX = int(xml.property.grid.@x_offset);
			m_OffsetY = int(xml.property.grid.@y_offset);
			m_Cols = int(xml.property.grid.@cols);
			m_Rows = int(xml.property.grid.@rows);
			m_Floor = int(xml.property.room.@floor);
			m_RoomID = xml.property.room.@roomid;
			m_Template = int(xml.property.room.@template);
			m_RealmID = int(xml.property.room.@realmid);
			
			var posX:int = int(xml.property.room.@gridx);
			var posY:int = int(xml.property.room.@gridy);
			setPosition(posX, posY );
			
			m_Data = xml;
			m_Loaded = true;
			m_DoorCount = 0;
			var list:XMLList = xml.objects.Doors.doorobj;
			for each (var elem:XML in list)
			{
				switch(String(elem.@direction))
				{
					case "SE":
						m_SEDoor = int(elem.@link);
						m_DoorCount++;
						break;
				
					case "SW":
						m_SWDoor = int(elem.@link);
						m_DoorCount++;
						break;
					
					case "NE":
						m_NEDoor = int(elem.@link);
						m_DoorCount++;
						break;
				
					case "NW":
						m_NWDoor = int(elem.@link);
						m_DoorCount++;
					break;
				}
			}
			
			m_ObjectCount = 0;
			//count the number of objects in the room
			list = xml.objects.Sprites;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			list = xml.objects.Statics;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			list = xml.objects.Monsters;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			list = xml.objects.Traps;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			list = xml.objects.ClickDecals;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			list = xml.objects.SpriteDecals;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			list = xml.objects.WallDecals;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			list = xml.objects.Clickables;
			for each (elem in list) if (elem != "") m_ObjectCount++;
			
		}
		
		
		
		public function get OffsetX():int { return m_OffsetX; } 
		public function get OffsetY():int { return m_OffsetY; } 
		public function get Cols():int { return m_Cols; } 
		public function get Rows():int { return m_Rows; } 
		public function get Floor():int { return m_Floor; } 
		public function get RealmID():int { return m_RealmID; } 
		public function get RealmLevel():int { return m_RealmLevel; } 
		public function get ObjectID():int { return m_ObjectID; } 
		public function get RoomID():String { return m_RoomID; } 
		public function get Template():int { return m_Template; } 
		public function get GridX():int { return m_GridX; } 
		public function get GridY():int { return m_GridY; } 
		public function get Data():XML { return m_Data; } 
		public function get Loaded():Boolean { return m_Loaded; }
		public function get ScreenX():int { if (m_StaticImage != null) return  m_StaticImage.x; else return  0; }
		public function get ScreenY():int { if (m_StaticImage != null) return  m_StaticImage.y; else return  0; }
		public function get Blocked():Boolean { return m_Blocked; }
		
		public function get SE_Door():int { return m_SEDoor; }
		public function get SW_Door():int { return m_SWDoor; }
		public function get NE_Door():int { return m_NEDoor; }
		public function get NW_Door():int { return m_NWDoor; }

		
		public function set RoomID(value:String):void { m_RoomID = value; } 
		public function set RealmLevel(value:int):void { m_RealmLevel = value; } 
		public function set ObjectID(value:int):void { m_ObjectID = value; } 
		public function set OffsetX(value:int):void { m_OffsetX = value; } 
		public function set OffsetY(value:int):void { m_OffsetY = value; } 
		public function set Cols(value:int):void { m_Cols = value; } 
		public function set Rows(value:int):void { m_Rows = value; } 
		public function set Floor(value:int):void { m_Floor = value; } 
		public function set Template(value:int):void { m_Template = value; } 
		public function set Data(value:XML):void { m_Data = value; } 
		
		public function set SE_Door(value:int):void { 
			m_SEDoor = value; 
			if (value > 0) 
				m_DoorCount++; 
			else if (m_DoorCount > 0)
				m_DoorCount--; 
		}
		public function set SW_Door(value:int):void { 
			m_SWDoor = value; 
			if (value > 0) 
				m_DoorCount++; 
			else if (m_DoorCount > 0)
				m_DoorCount--; 
		}
		public function set NE_Door(value:int):void { 
			m_NEDoor = value; 
			if (value > 0) 
				m_DoorCount++; 
			else if (m_DoorCount > 0)
				m_DoorCount--; 
			}
		public function set NW_Door(value:int):void { 
			m_NWDoor = value; 
			if (value > 0) 
				m_DoorCount++; 
			else if (m_DoorCount > 0)
				m_DoorCount--; 
		}

		public function get isConnected():Boolean { return m_DoorCount > 0; }
		public function get isEmpty():Boolean { return m_ObjectCount == 0; }
		public function get ObjectCount():int { return m_ObjectCount; }
		//figure out the objects 2d screen pos based on the tile it cupies
		public function setPosition(posX:int, posY:int):void
		{
			
			
			//trace(m_RealmLevel);
			switch(m_RealmLevel)
			{
				case 0:
					if ( posY < 2 || posX < 2) return;
					if ( posY > 4 || posX > 4) return;
					break;
				case 1:
					if ( posY < 1 || posX < 1) return;
					if ( posY > 5 || posX > 5) return;
					break;
				case 2:
					if ( posY == 0 && posX == 6) return;
					if ( posY == 6 && posX == 0) return;
					break;
			}
			
			
			m_GridY = posY;
			m_GridX = posX;
			
			//find 3D coordinates
			var iso_x:Number = m_GridX * m_TileWidth;
			var iso_z:Number = -m_GridY * m_TileHeight;
			
			//map 3D coordinates to the screen
			var screenCoord:IsoPoint = m_IsoUtil.mapToScreen(iso_x, 0, iso_z);
			
			//update display object with screen coordinates
			m_ScreenX = screenCoord.X - m_ScreenXOffset;
			m_ScreenY = screenCoord.Y - m_ScreenYOffset;
			
			if (m_StaticImage != null)
			{
				m_StaticImage.x = m_ScreenX + m_xOffset;
				m_StaticImage.y = m_ScreenY + m_yOffset;
			}
			//trace("x:" + m_ScreenX + " y:" + m_ScreenY);
			
		}
		
		public function addSelectEffect():void
		{
			if (m_StaticImage != null)
			{
				m_StaticImage.RemoveFilter();
				m_StaticImage.SetFilter(m_SelectEffect);
			}
		}
		
		public function addGlowEffect():void
		{
			if (m_StaticImage != null)
			{
				m_StaticImage.RemoveFilter();
				m_StaticImage.SetFilter(m_GlowEffect);
			}else
				m_ApplyGlow = true;
		}
		
		public function removeGlowEffect():void
		{
			if (m_StaticImage != null)
				m_StaticImage.RemoveFilter();
			m_ApplyGlow = false;
		}
		
	}

}