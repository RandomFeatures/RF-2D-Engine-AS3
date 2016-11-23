package com.random.iso.map 
{
	import com.random.iso.GameObjectManager;
	import com.random.iso.consts.*;
	import com.random.iso.GameObject;
	import com.random.iso.items.DoorObject;
	import com.random.iso.MobileObject;
	import com.random.iso.items.StaticObject;
	import com.random.iso.map.tile.Tile;
	import com.random.iso.map.tile.WayPoint;
	import com.random.iso.utils.astar.INode;
	import com.random.iso.utils.astar.ISearchable;
	import com.random.iso.utils.astar.Astar;
	import com.random.iso.utils.astar.Path;
	import com.random.iso.utils.astar.SearchResults;
	import com.random.iso.utils.IsoPoint;
	import com.random.iso.utils.IsoUtil;
	import com.random.iso.utils.TileAssetsUtil;
	import com.random.iso.characters.avatar.LayerCharacter;
	import com.random.iso.events.TileEvent
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import org.flixel.FlxSprite;
	import flash.geom.Matrix;
	import com.random.game.consts.StaticResources;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class IsoMap extends EventDispatcher implements ISearchable
	{
		

		
		public static const DATA_READY:String = "DATA_READY";
		public static const RENDER_READY:String = "RENDER_READY";
		
		private var m_Grid:Array;
        private var m_Cols:int;
		private var m_Rows:int;
        private var m_ScreenXOffset:int;
		private var m_ScreenYOffset:int;
		private var m_Floor:IsoFloorImage;
		private var m_LeftWall:IsoWallImage;
		private var m_RightWall:IsoWallImage;

		private var m_Floor_bak:IsoFloorImage = null;
		private var m_LeftWall_bak:IsoWallImage = null;
		private var m_RightWall_bak:IsoWallImage = null;
		private static var m_EditMode:Boolean = false;
		
		//width of tile in 3D
		private var m_TileWidth:Number;
		//height of tile in 3D
		private var m_TileHeight:Number;
		//width in 2D
		private var m_TileWidthOnScreen:int;
		//height of tile in 2D
		private var m_TileHeightOnScreen:int;
		
		//Isometric utilties
		private var m_IsoUtil:IsoUtil;
		private var m_Astar:Astar;
		
		private var m_LoadingXML:Boolean = false;
		private var m_ShowGrid:Boolean = false;
		
		private var m_XmlData:XML;

        // width & height of a grid cell prior to rotation
        private var m_CellWidth:Number = Math.sqrt(2048);
		private var m_BackGround:FlxSprite = null; //Flattened Background
		
		public function IsoMap()
		{
				
			m_IsoUtil = new IsoUtil();
			m_Astar = new Astar(this);
            Tile.setBitmapData(TileAssetsUtil.LEGAL_TILE_DATA, TileAssetsUtil.ILLEGAL_TILE_DATA,TileAssetsUtil.BLOCKED_TILE_DATA,TileAssetsUtil.THREAT_TILE_DATA);
			
			//when mapped to the screen the tile makes a diamond of these dimensions
			m_TileWidthOnScreen = GameConstants.TILEWIDTH;
			m_TileHeightOnScreen = GameConstants.TILEHEIGHT;
			
			//figure out the width of the tile in 3D space
			m_TileWidth = m_IsoUtil.mapToIsoWorld(GameConstants.TILEWIDTH, 0).X;
			
			//the tile is a square in 3D space so the height matches the width
			m_TileHeight = m_TileWidth;
			
		}
	
		public function get Columns():int { return m_Cols; }
        public function get Rows():int { return m_Rows; }
		public function get ScreenXOffset():int { return m_ScreenXOffset; }
		public function get ScreenYOffset():int {	return m_ScreenYOffset; }
		public function get TileWidth():int { return m_TileWidth; }
		public function get TileHeight():int { return m_TileHeight; }
		public function get A_Star():Astar { return m_Astar; }
		public static function set EditMode(value:Boolean):void { m_EditMode = value; }
		
		
		public function loadMapURL(url:String):void
		{
			var xmlLoader:URLLoader = new URLLoader();
			m_LoadingXML = true;
			m_XmlData = new XML();
			xmlLoader.addEventListener(Event.COMPLETE, onLoadXML);
			xmlLoader.load(new URLRequest(url));	
		}
		
		private function onLoadXML(e:Event):void {
			processMapXML(XML(e.target.data));
		}	

		public function processMapXML(xml:XML):void
		{
			m_XmlData = xml;
			m_ScreenXOffset = int(m_XmlData.property.grid.@x_offset);
			m_ScreenYOffset = int(m_XmlData.property.grid.@y_offset);
			m_Cols = int(m_XmlData.property.grid.@cols);
			m_Rows = int(m_XmlData.property.grid.@rows);
			//now that I now the offset tell everything!
			GameObject.setScreenOffset(m_ScreenXOffset, m_ScreenYOffset);	
			createGrid();
			m_LeftWall = new IsoWallImage(this, IsoWallImage.LEFT);
			m_LeftWall.loadFromXML(XML(m_XmlData.objects.Walls));
			m_RightWall = new IsoWallImage(this, IsoWallImage.RIGHT);
			m_RightWall.loadFromXML(XML(m_XmlData.objects.Walls));
			m_Floor = new IsoFloorImage(this);
			m_Floor.loadFromXML(XML(m_XmlData.objects.Floor));
			m_LoadingXML = false;
			dispatchEvent(new Event(DATA_READY));
		}
		
		public function toXML():String 
		{
			return floorToXML() + wallToXML();
		}
		
		public function floorToXML():String {
			return  m_Floor.toXML() ;	
		}
		
		public function wallToXML():String {
			var tmpStr:String;
			
			tmpStr = m_LeftWall.toXML();
			tmpStr = tmpStr + m_RightWall.toXML();
			return "<Walls>" + tmpStr + "</Walls>";
		}
		public function loadNewFloor(xml:XML):void
		{
			if (m_Floor){
				m_Floor_bak = m_Floor;
				m_RightWall_bak = null;
				m_LeftWall_bak = null;
			}
			m_ShowGrid = false;
			m_Floor = new IsoFloorImage(this);
			m_Floor.loadFromXML(xml);
		}

		public function loadNewWall(xml:XML):void
		{
			var type:int = 0;
			type = int(xml.rightwall.property.@type);
			if (type == 0) type = int(xml.leftwall.property.@type);
			
			switch (type)
			{
				case 0: //left
					if (m_LeftWall){
						m_LeftWall_bak = m_LeftWall;
						m_RightWall_bak = null;
						m_Floor_bak = null;
					}
					m_LeftWall = new IsoWallImage(this, IsoWallImage.LEFT);
					m_LeftWall.loadFromXML(xml);
					break;
				case 1://right
					if (m_RightWall) {
						m_RightWall_bak = m_RightWall;
						m_LeftWall_bak = null;
						m_Floor_bak = null;
					}
					m_RightWall = new IsoWallImage(this, IsoWallImage.RIGHT);
					m_RightWall.loadFromXML(xml);
					break;
			}
			//flatenBackground();
		}

		public function getNewStructure():IsoStructure {
			var rtn:IsoStructure = null;

			if (m_RightWall_bak != null){
				rtn = m_RightWall;
			}
			if (m_LeftWall_bak != null) {
				rtn = m_LeftWall;
			}
			if (m_Floor_bak != null) {
				rtn = m_Floor;
			}
			return rtn;	
		}
		
		public function saveStructure():IsoStructure {
			var rtn:IsoStructure = null;

			if (m_RightWall_bak != null){
				m_RightWall_bak.kill();
				m_RightWall_bak = null;
				rtn = m_RightWall;
			}
			if (m_LeftWall_bak != null) {
				m_LeftWall_bak.kill();
				m_LeftWall_bak = null;
				rtn = m_LeftWall;
			}
			if (m_Floor_bak != null) {
				m_Floor_bak.kill();
				m_Floor_bak = null;
				rtn = m_Floor;
			}
			
			m_ShowGrid = true;
			flatenBackground();
			
			return rtn;
			
		}

		public function cancelStructure():void {
			
			if (m_RightWall_bak != null)
			{
				m_RightWall = m_RightWall_bak;
				m_RightWall_bak = null;
			}	
			if (m_LeftWall_bak != null) {
				m_LeftWall = m_LeftWall_bak;
				m_LeftWall_bak = null;
			}
			if (m_Floor_bak != null) {
				m_Floor = m_Floor_bak;
				m_Floor_bak = null;
				
			}
			m_ShowGrid = true;
			flatenBackground();
		}

		
		public function renderGrid():void
		{
			if (!m_LoadingXML && m_ShowGrid)
			for (var i:int = 0; i < m_Cols;++i) {
				for (var j:int = 0; j < m_Rows;++j) {
					Tile(m_Grid[i][j]).TileImage.render();
				}
			}	
		}
		public function cleanUp():void
		{
			if (m_Floor){
				m_Floor.kill();
				m_Floor = null;
			}
			
			if (m_LeftWall){
				m_LeftWall.kill();
				m_LeftWall = null;
			}
			
			if (m_RightWall) {
				m_RightWall.kill();
				m_RightWall = null;
			}
			destroyGrid();
		}
		
		public function flatenBackground():void
		{
			if (m_LeftWall && m_LeftWall.Ready)
			if (m_RightWall && m_RightWall.Ready)
			if (m_Floor && m_Floor.Ready)
			{
				//new tmp bmp
				var _image:Bitmap = new StaticResources.MapBG();

				//var newPixels:BitmapData = new BitmapData(760,555,false,0xff4d7398);
				var newPixels:BitmapData = _image.bitmapData;
				
				//0xff4d7398
				var mtx:Matrix = new Matrix();
				mtx = new Matrix();
				mtx.scale(1,1);
				mtx.translate(m_Floor.xOffset,m_Floor.yOffset);
				//render the floor on to the tmp bmp
				newPixels.draw(m_Floor.pixels, mtx);
				
				//position matrix
				
				mtx = new Matrix();
				mtx.scale(1,1);
				mtx.translate(m_LeftWall.xOffset,m_LeftWall.yOffset);
				//render the first wall onto the tmp bmp
				newPixels.draw(m_LeftWall.pixels,mtx);
				//delete(mtx);
				
				mtx = new Matrix();
				mtx.scale(1,1);
				mtx.translate(m_RightWall.xOffset,m_RightWall.yOffset);
				//render the second wall onto the tmp bmp
				newPixels.draw(m_RightWall.pixels,mtx);
				//delete(mtx);
				
			
				
				
				if (m_ShowGrid)
				for (var i:int = 0; i < m_Cols;++i) {
					for (var j:int = 0; j < m_Rows;++j) {
						mtx = new Matrix();
						mtx.scale(1,1);
						mtx.translate(Tile(m_Grid[i][j]).TileImage.x ,Tile(m_Grid[i][j]).TileImage.y);
						newPixels.draw(Tile(m_Grid[i][j]).TileImage.pixels, mtx);
						//delete(mtx);
					}
				}	
				
				m_BackGround = new FlxSprite()
				m_BackGround.pixels = newPixels;
				
				dispatchEvent(new Event(RENDER_READY));
			}
		}
		
		public function render():void
		{
			if (m_BackGround)
				m_BackGround.render();

/*
			if (m_leftWall && m_leftWall.ready)
				m_leftWall.render();
			if (m_rightWall && m_rightWall.ready)
				m_rightWall.render();
			if (m_floor && m_floor.ready)
				m_floor.render();
				*/

			
		}
		
		public function update():void
		{
			
		}
		
		/**
		 * Creates all tiles needed based on the size of the world
		 */
		private function createGrid():void {
					
			m_Grid = [];
            var coord:IsoPoint;
			for (var i:int = 0; i < m_Cols;++i) {
				m_Grid[i] = [];
				for (var j:int = 0; j < m_Rows;++j) {
					var t:Tile = new Tile();
					t.Col = i;
					t.Row = j;
                    coord = m_IsoUtil.mapToScreen(i * m_CellWidth, 0, -j * m_CellWidth);
                    t.TileImage.x = coord.X - 32 - m_ScreenXOffset;
                    t.TileImage.y = coord.Y - m_ScreenYOffset;
					//t.disable();
					//t.tileImage.alpha = 0.8;
					m_Grid[i][j] = t;
				}
			}
		}
	
		private function destroyGrid():void
		{
			for (var i:int = 0; i < m_Cols;++i) {
				for (var j:int = 0; j < m_Rows;++j) {
					delete(Tile(m_Grid[i][j]));
				}
			}	
			
			m_Grid = [];
		}
		
		/**
		 * Returns a tile based on screen coordinates. Null is returned if the position is invalid.
		 * @param	screen x coordinate
		 * @param	screen y coordinate
		 * @return	the tile found at those coordinates, or null
		 */
		public function getTileFromScreenCoordinates(tx:int, ty:int):Tile {
			var coord:IsoPoint = m_IsoUtil.mapToIsoWorld(tx+m_ScreenXOffset, ty+m_ScreenYOffset);
			var col:int = Math.floor(coord.X / m_TileWidth);
			var row:int = Math.floor( -coord.Z / m_TileHeight);
			
			return getTile(col, row);
		}
		
		
		
		/**
		 * Returns the tile based on column and row
		 * @param	column
		 * @param	row
		 * @return	the tile or null
		 */
		public function getTile(col:int, row:int):Tile {
			if (col < m_Cols && col >=0 && row < m_Rows && row >=0 ) {
				return m_Grid[col][row];
			} else {
				return null;
			}
		}
		public function toggleGrid():void {
			m_ShowGrid = !m_ShowGrid;
			
			if(m_ShowGrid)
				flatenBackground();

		}
		
		public function showGrid():void	{
			
			m_ShowGrid = true;
			flatenBackground();
		}
		
		public function hideGrid():void	{
			m_ShowGrid = false;
			flatenBackground();
		}
	/* INTERFACE com.random.iso.utils.astar.ISearchable */
		
		public function getCols():int{
			return m_Cols;
		}
		
		public function getRows():int{
			return m_Rows;
		}
		
		public function getNode(col:int, row:int):INode{
			return getTile(col, row);
		}
		
		public function getNodeTransitionCost(n1:INode, n2:INode):Number {
			var cost:Number = 1;
			
			if (!Tile(n1).Walkable || !Tile(n2).Walkable) {
				cost = 100000;
			}
			return cost;
		}
        
	
		
		/**
		 * Places and item into the map
		 * @param	Item to be placed
		 */
		public function placeItem(item:GameObject):void {
			
			//tell all the tiles the item is touching about the item. tell the item about all the tiles.
			for (var j:int = item.xPos;j < item.xPos + item.Cols; ++j) {
				for (var i:int = item.yPos;i < item.yPos + item.Rows; ++i) {
					var t:Tile = getTile(j, i);
					if (t)
					{
						
						if (!item.Walkable || item.EditMode)
						{
							t.addItem(item);
							item.addTile(t);
						}
					}
				}
			}
			if (m_ShowGrid)
				flatenBackground();
				
		}
		
		/**
		 * Places and monster into the map
		 * @param	monster to be placed
		 */
		public function placeMonster(item:GameObject):void {
			
			var count:int = 0;
			//tell all the tiles the item is touching about the item. tell the item about all the tiles.
			for (var j:int = item.xPos-2;j < item.xPos-2 + item.ThreatCols; ++j) {
				for (var i:int = item.yPos-2;i < item.yPos-2 + item.ThreatRows; ++i) {
					var t:Tile = getTile(j, i);
					if (t)
					{
						t.addMonster(item);
						item.addTile(t);
					}
				}
			}
			if (m_ShowGrid)
				flatenBackground();
				
		}
		
		
		/**
		 * Checks to see if the item can be placed on that tile. It takes into account all tiles in the span of the item.
		 * @param	The item to be placed
		 * @return	returns true if it is a valid placement
		 */
		public function placementTest(item:GameObject):Boolean {
			var valid:Boolean = true;
			var tile:Tile = getTile(item.xPos, item.yPos);
			var i:int;
			var j:int;
			var t:Tile;
		
			
			if (item is DoorObject)
			{//make sure door objects stay on their wall
					if (DoorObject(item).DoorType == 0)
					{
						if ((item.yPos != 0) && (item.Dir == IsoConstants.DIR_NE))
							valid = false;
						if ((item.Dir == IsoConstants.DIR_NW) && (item.xPos != 0))
							valid = false;
					}
					else
					{
						if ((item.xPos != m_Cols-1) && (item.Dir == IsoConstants.DIR_SE))
							valid = false;
						if ((item.Dir == IsoConstants.DIR_SW) && (item.yPos != m_Rows-1))
							valid = false;
					}
			}else
				if ((item.Layer == 1) && (item.xPos != 0) && (item.yPos != 0))
				{
					valid = false;
				}
			
			if (valid)
			{//still good so check the other tiles
				if (!item.Overlap)
				{//current item can not be over lapped
					for (i = tile.Col; i < tile.Col + item.Cols;++i) {
						for (j = tile.Row; j < tile.Row + item.Rows;++j) {
							t = getTile(i, j);
							if (t == null || !t.allowsItemPlacement()) {
								valid = false;
								break;
							}
						}
					}	
				}else { //item can be over laped so just make sure it is on the map
					for (i = tile.Col; i < tile.Col + item.Cols;++i) {
						for (j = tile.Row; j < tile.Row + item.Rows;++j) {
							t = getTile(i, j);
							if (t == null) {
								valid = false;
								break;
							}
						}
					}	
				}
			}
			return valid;
		}
		
		
		/**
		 * Checks to see if the item can be placed on that tile. It takes into account all tiles in the span of the item.
		 * @param	The item to be placed
		 * @return	returns true if it is a valid placement
		 */
		public function getEmptyTile():Point {
			var t:Tile;
			var rtn:Point = null;
			
			for (var i:int = 0; i < m_Cols;++i) {
				for (var j:int = 0; j < m_Rows;++j) {
					t = getTile(i, j);
					if (t != null ) 
					 if (t.Walkable)
						return new Point(i, j);
				}
			}	
			
			return rtn;
			
		}
		
		
				
		/**
		 * Checks to see if the item can be placed on that tile. It takes into account all tiles in the span of the item.
		 * @param	The item to be placed
		 * @return	returns true if it is a valid placement
		 */
		public function getEmptyTileFromCenter():Point {
			var t:Tile;
			var rtn:Point = null;
			var startX:int = (m_Cols / 2);
			var startY:int = (m_Rows / 2);
			
			for (var i:int = startX; i < m_Cols;++i) {
				for (var j:int = startY; j < m_Rows;++j) {
					t = getTile(i, j);
					if (t != null ) 
					 if (t.Walkable)
						return new Point(i, j);
				}
			}	
			
			//didnt fine one so start up in the corner and come down.
			rtn = getEmptyTile();
			
			return rtn;
			
		}
		
		
		
		public function removeItem(item:GameObject):void {
			
			//remove a reference to the item on all of the tiles it was touching. remove all the tile references from the item.
			if (item.TilesList != null)
			for (var i:int = item.TilesList.length - 1; i >= 0;--i) {
				var t:Tile = item.TilesList[i];
				item.removeTile(t);
				t.removeItem(item);
			}
			
			//rebuild the background with the new grid
			if (m_ShowGrid)
			{
				if(m_BackGround) m_BackGround.kill();
				flatenBackground();
			}
		}
		public function removeMonster(item:GameObject):void {
			
			//remove a reference to the item on all of the tiles it was touching. remove all the tile references from the item.
			for (var i:int = item.TilesList.length - 1; i >= 0;--i) {
				var t:Tile = item.TilesList[i];
				item.removeTile(t);
				t.removeMonster(item);
			}
			item.clearTileList();
			//rebuild the background with the new grid
			if (m_ShowGrid)
			{
				if(m_BackGround) m_BackGround.kill();
				flatenBackground();
			}
		}
		
		
		public function getDistance(t1:Tile, t2:Tile):Number {
			var dis:Number = Math.sqrt(Math.pow((t1.Col - t2.Col) * m_TileWidth , 2) + Math.pow((t1.Row - t2.Row) * m_TileHeight, 2));
			return dis;
		}
	}
}