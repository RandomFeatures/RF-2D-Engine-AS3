package com.random.iso.map 
{
	import com.random.iso.map.Room;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class Realm
	{
		private var m_RoomList:Array = [];
		private var m_FloorCount:int;
		private var m_RoomCount:int = 0;
		private var m_GridRows:int;
		private var m_GridCols:int;
		private var m_StartRoomID:int;
		private var m_ChestRoomID:int;
		private var m_CurrentRoomID:int;
		private var m_StartRoom:Room;
		private var m_ChestRoom:Room;
		private var m_CurrentRoom:Room;
		private var m_RealmID:int;
		private var m_ChestPopped:Boolean = false;
		private var m_RealmBuilder:int = 1;
		private var m_Adventure:int = 1;
		
		private var m_RealmLevel:int = -1;
		private var m_MonsterLevel:int = 0;
		private var m_TrapLevel:int = 0;
		
		public function Realm() 
		{
			
		}
		
		public function get FloorCount():int { return m_FloorCount; }
		public function get RoomCount():int { return m_RoomCount; }
		public function get GridRows():int { return m_GridRows; }
		public function get GridCols():int { return m_GridCols; }
		public function get StartRoomID():int { return m_StartRoomID; }
		public function get ChestRoomID():int { return m_ChestRoomID; }
		public function get CurrentRoomID():int { return m_CurrentRoomID; }
		public function get RealmID():int { return m_RealmID; }
		public function get ChestPopped():Boolean { return m_ChestPopped; }

		public function get RealmBuilderActive():int { return m_RealmBuilder; }
		public function get AdventureActive():int { return m_Adventure; }

		public function get CurrentRoom():Room { return m_CurrentRoom; }
		public function get StartRoom():Room { return m_StartRoom; }
		public function get ChestRoom():Room { return m_ChestRoom; }
		
		public function get RealmLevel():int { return m_RealmLevel; }
		public function get MonsterLevel():int { return m_MonsterLevel; }
		public function get TrapLevel():int { return m_TrapLevel; }
		
		
		
		public function set FloorCount(value:int):void { m_FloorCount = value; }
		public function set RoomCount(value:int):void { m_RoomCount = value; }
		public function set GridRows(value:int):void { m_GridRows = value; }
		public function set GridCols(value:int):void { m_GridCols = value; }
		public function set RealmID(value:int):void { m_RealmID = value; }
		public function set ChestPopped(value:Boolean):void { m_ChestPopped = value; }

		public function set RealmLevel(value:int):void { m_RealmLevel = value; }
		public function set MonsterLevel(value:int):void { m_MonsterLevel = value; }
		public function set TrapLevel(value:int):void { m_TrapLevel = value; }

		
		public function set StartRoomID(value:int):void 
		{ 
			m_StartRoomID = value; 
			m_StartRoom = getRoom(String(m_StartRoomID));
		}
		public function set StartRoom(value:Room):void 
		{ 
			m_StartRoomID = int(value.RoomID); 
			m_StartRoom = value;
		}
		public function set ChestRoomID(value:int):void 
		{ 
			m_ChestRoomID = value; 
			m_ChestRoom = getRoom(String(m_ChestRoomID));
		}
		public function set ChestRoom(value:Room):void 
		{ 
			m_ChestRoomID = int(value.RoomID); 
			m_ChestRoom = value;
		}
		public function set CurrentRoomID(value:int):void 
		{ 
			m_CurrentRoomID = value; 
			m_CurrentRoom = getRoom(String(m_CurrentRoomID));
		}
		public function set CurrentRoom(value:Room):void 
		{ 
			if (value != null)
			{
				m_CurrentRoomID = int(value.RoomID); 
				m_CurrentRoom = value;
			}
		}
		
		public function parseRealmXML(xml:XML):void
		{
			m_FloorCount = int(xml.dataset.property.@floorcount);
			//m_RoomCount = int(xml.dataset.property.@roomcount);
			m_RoomCount = 0;
			m_GridRows = int(xml.dataset.property.@gridrows);
			m_GridCols = int(xml.dataset.property.@gridcols);
			m_StartRoomID = int(xml.dataset.property.@startroom);
			m_ChestRoomID = int(xml.dataset.property.@chestroom);
			
			m_RealmBuilder = int(xml.dataset.property.@realmbuilder);
			m_Adventure = int(xml.dataset.property.@adventure);

			m_RealmLevel = int(xml.dataset.property.@realmlevel);
			m_MonsterLevel = int(xml.dataset.property.@monsterlevel);
			m_TrapLevel = int(xml.dataset.property.@traplevel);
			
			var list:XMLList = xml.dataset.room
			var newRoom:Room;
			for each (var elem:XML in list)
			{
				//put each room into the realm list
				newRoom = new Room(0, m_RealmLevel);
				//newRoom.RealmLevel = m_RealmLevel;
				newRoom.LoadFromXML(elem);
				m_RoomList.push(newRoom);
				m_RoomCount++;
			}
			
			for each (var room:Room in m_RoomList)
			{
				if (room.RoomID == String(m_StartRoomID) )
				{
					m_StartRoom = room;
					m_RealmID = m_StartRoom.RealmID;
					//trace(m_RealmID);
				}
				if (room.RoomID == String(m_ChestRoomID) ) 
					m_ChestRoom = room;
			}	
			
		}
		
		public function AddNewRoom(r:Room):void {
			m_RoomList.push(r);
		}
		
		public function getRoomXML(roomid:String):XML
		{
			var room:Room;
			var xml:XML;
			
			
			room = getRoom(roomid);
			if (room)
				xml = room.Data;
			
			return xml;
		}

		public function getRoomAt(posx:int, posy:int, floor:int):Room {
			var rtn:Room = null;
			for each (var room:Room in m_RoomList)
			{
				if (room.Floor == floor) 
				if (room.GridX == posx && room.GridY == posy) 
				{
					rtn = room;
					break;
				}
			}	
			return rtn;
		}
		
		public function getRoom(roomid:String):Room
		{
			var rtn:Room = null;
			for each (var room:Room in m_RoomList)
			{
				if (room.RoomID == roomid) 
				{
					rtn = room;
					break;
				}
			}	
			return rtn;
		}
		
		public function removeRoom(roomid:String):void {
			
			for (var i:int = 0; i < m_RoomList.length;++i) {
				if (m_RoomList[i].RoomID == roomid) {
					m_RoomList.splice(i, 1);
					break;
				}
			}
		}
		
		public function getRooms(floor:int):Array
		{
			var rtn:Array = [];
			for each (var room:Room in m_RoomList)
			{
				if (room.Floor == floor) 
				{
					rtn.push(room);
				}
			}	
			return rtn;
		}
	}

}