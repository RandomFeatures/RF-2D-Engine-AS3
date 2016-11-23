package com.random.iso.map 
{
	import com.random.iso.GameObject;
	import com.random.iso.items.StaticObject;
	import com.random.iso.items.SpriteObject;
	import com.random.iso.items.TrapObject;
	import com.random.iso.map.tile.Tile;
	import com.random.iso.map.IsoMap;
	import com.random.iso.MobileObject;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class DragGrid
	{
		
		private var m_Map:IsoMap;
		private var m_DragGrid:Array;
		private var m_Cols:int;
		private var m_Rows:int;
		private var m_Enabled:Boolean;
		private var m_StartX:int = 0;
		private var m_StartY:int = 0;
		
		
		public function DragGrid(map:IsoMap) 
		{
			m_DragGrid = [];
			m_Map = map;
		}
		
		public function set StartX(value:int):void { m_StartX = value; }
		public function set StartY(value:int):void { m_StartY = value; }
		
		public function get StartX():int { return m_StartX; }
		public function get StartY():int { return m_StartY; }
		
		public function set Enabled(value:Boolean):void { m_Enabled = value; }
		public function get Enabled():Boolean { return m_Enabled; }
		/**
		 * Creates all tiles needed based on the size of the world
		 */
		public function createDragGrid(item:GameObject):void {
						
			//clear old grid
			for (var iLoop:int = 0; iLoop < m_DragGrid.length;++iLoop) {
				 delete m_DragGrid[iLoop];	
			}
			var i:int;
			var j:int;
			var t:Tile
			
			m_DragGrid = [];
            if (item is StaticObject)
			{
				m_Cols = item.Cols;
				m_Rows = item.Rows;
				for (i = 0; i < m_Cols;++i) {
					for (j = 0; j < m_Rows;++j) {
						t = new Tile();
						t.blocked();
						m_DragGrid.push(t);
					}
				}
			}else if (item is SpriteObject)
			{
				m_Cols = item.Cols;
				m_Rows = item.Rows;
				for (i = 0; i < m_Cols;++i) {
					for (j = 0; j < m_Rows;++j) {
						t = new Tile();
						t.blocked();
						m_DragGrid.push(t);
					}
				}
			}else if (item is MobileObject ) {
				m_Cols = item.ThreatCols;
				m_Rows = item.ThreatRows;
				for (i = 0; i < m_Cols;++i) {
					for (j = 0; j < m_Rows;++j) {
						t = new Tile();
						t.threat();
						m_DragGrid.push(t);
					}
				}
				
			}else if (item is TrapObject) {
				m_Cols = item.ThreatCols;
				m_Rows = item.ThreatRows;
				for (i = 0; i < m_Cols;++i) {
					for (j = 0; j < m_Rows;++j) {
						t = new Tile();
						t.threat();
						m_DragGrid.push(t);
					}
				}
			}
			m_Enabled = true;
			m_StartX = item.xPos;
			m_StartY = item.yPos;
			
		}
		
		public function moveItem(item:GameObject):void
		{
			
			var indx:int = 0;
			var offset:int = 0;
			var valid:Boolean = m_Map.placementTest(item);
			var imgx:int;
			var imgy:int;
			var rows:int = item.Rows;
			var cols:int = item.Cols;
			if (item is MobileObject || item is TrapObject)
			{
				offset = -2;
				rows = item.ThreatRows;
				cols = item.ThreatCols;
			}
			
						
			for (var i:int = item.xPos+offset;i < item.xPos+offset + cols; ++i) {
				for (var j:int = item.yPos+offset;j < item.yPos+offset + rows; ++j) {

					if (indx > m_DragGrid.length-1) break;
					
					//get the x,y of the tile to represent
					var maptile:Tile = m_Map.getTile(i, j);
					
					if (!maptile)
					{//if dont find a tile then the area is off the map so just hide the tiles off in nowhere
						imgx = -50;
						imgy = -50;
					}else
					{//match the tile up with the map tile it is covering
						imgx = maptile.TileImage.x;
						imgy = maptile.TileImage.y;
					}
					
					if (valid)
					{
						//if ((item.Layer == 1) && (item.xPos != 0) && (item.yPos != 0))
						//{//show it as illegal to move layer 1 items off the wall. 
						//	Tile(m_DragGrid[indx]).illegal();
						//}else
						//{
							if ((item is StaticObject) || (item is SpriteObject))
								Tile(m_DragGrid[indx]).blocked();
							else
								Tile(m_DragGrid[indx]).threat();
						//}
						
					}
					else	
						Tile(m_DragGrid[indx]).illegal();
						
					Tile(m_DragGrid[indx]).Col = i;
					Tile(m_DragGrid[indx]).Row = j;
                    Tile(m_DragGrid[indx]).TileImage.x = imgx;
                    Tile(m_DragGrid[indx]).TileImage.y = imgy;
					indx +=1;
				}
			}	
		}
		
		public function render():void {
			if(m_Enabled)
			for (var i:int = 0; i < m_DragGrid.length;++i) {
				Tile(m_DragGrid[i]).TileImage.render();
			}
		}
		
	}

}