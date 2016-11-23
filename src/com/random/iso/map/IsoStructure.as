package com.random.iso.map 
{
	import org.flixel.FlxLoadSprite;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class IsoStructure extends FlxLoadSprite
	{
		
		//UI Protperties
		protected var m_ItemID:int;
		protected var m_ItemName:String;
		protected var m_ToolTip:String;
		protected var m_BuckCost:int;
		protected var m_CoinCost:int;
		protected var m_IconFile:String;
		protected var m_ItemType:int;
		
		public function IsoStructure() 
		{
			 super();
		}
		//UI properties
		public function get ItemID():int { return m_ItemID };
		public function get ItemName():String { return m_ItemName };
		public function get ToolTip():String { return m_ToolTip };
		public function get BuckCost():int { return m_BuckCost };
		public function get CoinCost():int { return m_CoinCost };
		public function get IconFile():String { return m_IconFile };
		public function get ItemType():int { return m_ItemType };
		
		//UI properties
		public function set ItemID(value:int):void  { m_ItemID = value;  };
		public function set ItemName(value:String):void  { m_ItemName = value; };
		public function set ToolTip(value:String):void  { m_ToolTip = value; };
		public function set BuckCost(value:int):void  { m_BuckCost = value; };
		public function set CoinCost(value:int):void  { m_CoinCost = value; };
		public function set IconFile(value:String):void  { m_IconFile = value; };
		public function set ItemType(value:int):void  { m_ItemType = value; };
		
		public function getEditorData(xml:XML):void
		{
			m_ItemID = int(xml.property.@id);
			m_ItemName = xml.property.@itemname;
			m_ItemType = int(xml.property.@type);
			m_ToolTip = xml.property.@tooltip;
			m_IconFile = xml.property.@iconfile;
		}
		
	}

}