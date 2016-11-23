package com.random.iso.map.tile {
	import com.random.iso.characters.monsters.MonsterCharacter;
	import com.random.iso.GameObject;
	import com.random.iso.MobileObject;
	import com.random.iso.items.TrapObject;
	import com.random.iso.utils.astar.INode;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class Tile implements INode {
		
		private static var IDS:int = 0;
		
        /**
         * @private
         * static tile renderables
         */
        private static var m_LegalData:BitmapData;
        private static var m_IllegalData:BitmapData;
        private static var m_BlockedData:BitmapData;
        private static var m_ThreatData:BitmapData;
        
        /**
         * @private
         * tile bitmap
         */
        private var m_TileImage:FlxSprite = new FlxSprite();
        
		private var m_Col:int;
		private var m_Row:int;
		private var m_ItemsList:Array;
		private var m_BaseWalkability:Boolean;
		private var m_BasePlaceability:Boolean;
		private var m_Walkable:Boolean;
		private var m_h:Number;
		private var m_Neighbors:Array;
		private var m_NodeId:String;
		private var m_NodeType:String;
        private var m_Enabled:Boolean;
		
		public function Tile() {
			++IDS;
			m_NodeId = IDS.toString();
			m_NodeType = "normal";
			
			m_ItemsList = [];
			m_BaseWalkability = true;
			m_BasePlaceability = true;
			m_Walkable = true;
            m_Enabled = true;
         	addGridPiece();
		}
        
         /**
         * Store the BitmapData used to determine which tile type to render.
         * 
         * @param	legal BitmapData that represents a "legal" tile state.
         * 
         * @param	illegal BitmapData that represents an "illegal" tile state.
		 * 
		 * @param	blocked BitmapData that represents an "blocked" tile state.
		 * 
		 * @param	threat BitmapData that represents an "threat" tile state.
         */
        public static function setBitmapData(legal:BitmapData, illegal:BitmapData, blocked:BitmapData, threat:BitmapData):void {
            m_LegalData = legal;
            m_IllegalData = illegal;
			m_BlockedData = blocked;
			m_ThreatData = threat;
			
        }
		
		public function addItem(item:GameObject):void {
			m_ItemsList.push(item);
            addGridPiece();
			determineWalkability();
		}

		public function addMonster(item:GameObject):void {
			m_ItemsList.push(item);
			m_TileImage.pixels = m_ThreatData;
			if(item.EditMode)
				determineMonsterWalkability();
		}

		private function addGridPiece():void
		{
			if (m_LegalData && m_IllegalData && m_TileImage)
                m_TileImage.pixels = allowsItemPlacement() ? m_LegalData : m_BlockedData;
		}
		
		public function fromXML(info:XML):void {
			
			m_BaseWalkability = info.@walkability == "false" ? false : true;
			m_BasePlaceability = info.@placeability == "false" ? false : true;
			if (m_LegalData && m_IllegalData && m_TileImage)
                m_TileImage.pixels = allowsItemPlacement() ? m_LegalData : m_BlockedData;
			
		}
		
		public function toXML():String
		{
			return "<Tile col='" + m_Col + "' row='" + m_Row + "' walkability='" + m_BaseWalkability + "' placeability='" + m_BasePlaceability + "' />";
		}
		
		public function allowsItemPlacement():Boolean {
			var allows:Boolean = true;
			if (!m_Enabled) {
				return false;
            }
			if (allows) {
				for (var i:int = 0; i < m_ItemsList.length;++i) {
					var item:GameObject = m_ItemsList[i];
					
					if (item is MobileObject)
					{//trying to place a non static on a mobile
						if ((item.xPos == this.m_Col) && (item.yPos == this.Row))
						allows = false;
						break;
					}
					if (item is TrapObject)
					{//trying to place a non static on a trap
						if ((item.xPos == this.m_Col) && (item.yPos == this.Row))
						allows = false;
						break;
					}
					
					
					if (!item.Overlap) {
						allows = false;
						break;
					}
				}
			}
			return allows;
		}
		public function allowsMobilePlacement():Boolean {
			var allows:Boolean = m_BasePlaceability;
            if (!m_Enabled) {
                return false;
            }
			if (allows) {
				for (var i:int = 0; i < m_ItemsList.length;++i) {
					var item:GameObject = m_ItemsList[i];
					if (item is MobileObject)
					{//trying to place a non static on a mobile
						allows = false;
						break;
					}
					if (item is TrapObject)
					{//trying to place a non static on a trap
						allows = false;
						break;
					}
					if (!item.Overlap) {
						allows = false;
						break;
					}
				}
			}
			return allows;
		}
		
		private function determineWalkability():void {
			var w:Boolean = m_BaseWalkability;
			if (w) {
				for (var i:int = 0; i < m_ItemsList.length;++i) {
					var item:GameObject = m_ItemsList[i];
					if (!item.Walkable) {
						w = false;
						break;
					}
				}
			}
			
			m_Walkable = m_Enabled && w;
			
		}
		
		private function determineMonsterWalkability():void {
			var w:Boolean = m_BaseWalkability;
			if (w) {
				for (var i:int = 0; i < m_ItemsList.length;++i) {
					
					if (m_ItemsList[i] is MonsterCharacter)
					{
						var mob:MonsterCharacter = m_ItemsList[i];	
						//only do this on the anchor tile
						if(mob.xPos == this.m_Col && mob.yPos == this.m_Row)
							w = false;
						break;
					}
				}
			}
			
			m_Walkable = m_Enabled && w;
			
		}

		private function determineThreat():void {
			for (var i:int = 0; i < m_ItemsList.length;++i) {
				var item:GameObject = m_ItemsList[i];
				if (item.ThreatCols > 0 && item.ThreatRows > 0) {
					m_TileImage.pixels = m_ThreatData;
					break;
				}
			}
		}
		
		public function removeItem(item:GameObject):void {
			for (var i:int = 0; i < m_ItemsList.length;++i) {
				if (m_ItemsList[i] == item) {
					m_ItemsList.splice(i, 1);
					break;
				}
			}
            if (m_LegalData && m_IllegalData && m_TileImage) {
                m_TileImage.pixels = allowsItemPlacement() ? m_LegalData : m_BlockedData;
			}
			determineThreat();
			determineWalkability();
			
		}
		
		public function removeMonster(item:GameObject):void {
			for (var i:int = 0; i < m_ItemsList.length;++i) {
				if (m_ItemsList[i] == item) {
					m_ItemsList.splice(i, 1);
					break;
				}
			}
            if (m_LegalData && m_IllegalData && m_TileImage) {
                m_TileImage.pixels = allowsItemPlacement() ? m_LegalData : m_BlockedData;
			}
			determineThreat();
		}
		
		/* INTERFACE com.random.iso.utils.astar.INode */
		
		public function setHeuristic(h:Number):void{
			m_h = h;
		}
		
		public function getHeuristic():Number{
			return m_h;
		}
		
		public function getCol():int{
			return m_Col;
		}
		
		public function getRow():int{
			return m_Row;
		}
		
		public function setNeighbors(arr:Array):void{
			m_Neighbors = arr;
		}
		
		public function getNodeId():String{
			return m_NodeId;
		}
		
		public function getNeighbors():Array{
			return m_Neighbors;
		}
		
		public function getNodeType():String{
			return m_NodeType;
		}
		
		public function setNodeType(type:String):void{
			m_NodeType = type;
		}
		
		public function get Col():int { return m_Col; }
		
		public function set Col(value:int):void {
			m_Col = value;
		}
		
		public function get Row():int { return m_Row; }
		
		public function set Row(value:int):void {
			m_Row = value;
		}
		
		public function get BaseWalkability():Boolean { return m_BaseWalkability; }
		
		public function set BaseWalkability(value:Boolean):void {
			m_BaseWalkability = value;
			
			  if (m_LegalData && m_IllegalData && m_TileImage)
				m_TileImage.pixels = m_BaseWalkability ? m_LegalData : m_BlockedData;
		}
		
		
		public function get Walkable():Boolean { return m_Walkable; }
		
		public function get BasePlaceability():Boolean { return m_BasePlaceability; }
		
		public function set BasePlaceability(value:Boolean):void {
			m_BasePlaceability = value;
			 if (m_LegalData && m_IllegalData && m_TileImage)
				m_TileImage.pixels = allowsItemPlacement() ? m_LegalData : m_BlockedData;
		}
        
        public function enable():void {
            m_Enabled = true;
            if (m_LegalData && m_IllegalData && m_TileImage)
				m_TileImage.pixels = allowsItemPlacement() ? m_LegalData : m_BlockedData;
        }
        
        public function disable():void {
            m_Enabled = false;
            if (m_LegalData && m_IllegalData && m_TileImage)
				m_TileImage.pixels = allowsItemPlacement() ? m_LegalData : m_BlockedData;
        }

		public function blocked():void {
			m_TileImage.pixels = m_BlockedData;
		}

		public function threat():void {
			m_TileImage.pixels = m_ThreatData;
		}

		
		public function illegal():void {
			m_TileImage.pixels = m_IllegalData;
		}
        /**
         * The renderable bitmap representation of the tile object.
         */
        public function get TileImage():FlxSprite {
            return m_TileImage;
        }
		
		public function get ItemsList():Array { return m_ItemsList; }
	}
	
}
