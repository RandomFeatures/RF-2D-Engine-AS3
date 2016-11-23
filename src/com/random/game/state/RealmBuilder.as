package com.random.game.state 
{
	import com.random.iso.GameObject;
	import com.random.iso.map.Realm;
	import com.random.iso.map.Room;
	import com.random.iso.ui.QuestionBox;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import com.random.game.UI.ContextMenuManager;
	import com.random.iso.GameState;
	import com.random.iso.GameObjectManager;
	import com.random.iso.ui.ContextMenu;
	import com.random.iso.ui.ContextMenuItem;
	import com.random.iso.ui.ContextMenu;
	import com.random.iso.consts.ObjTypes;
	import com.random.game.consts.RealmConsts;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	import flash.events.MouseEvent;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import LoAUIEvent;
	import com.random.game.objmanager.RealmManager
	import flash.net.URLLoader;
	import flash.display.MovieClip;
	import com.random.game.AvatarStats;
	import events.UpdateUIEvent;
	import com.random.iso.map.IsoMap;
	import org.flixel.FlxSound;
	import com.random.iso.consts.GameConstants;
	import com.random.game.consts.GameModeConst;
	import com.random.iso.ui.ToolTips;
	import flash.events.KeyboardEvent;
	import com.random.game.consts.Globals;
	import com.random.game.UI.MsgBoxManager;
	import com.random.iso.consts.MsgConstants;
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class RealmBuilder extends RealmState
	{
	
		 /**
         * @private
         * legal tile
         */
		private var m_PopupMenu:ContextMenuManager;
		private var m_UIInit:Boolean = false;
		private var m_RealmStoreUILoader:Loader;
		private var m_StoreUILoader:Loader;
		private var m_HeaderUILoader:Loader;
		private var m_HeaderMovieClip:MovieClip;
		private var m_BuilderMovicClip:MovieClip;
		private var m_StoreUIMovicClip:MovieClip;
		private var m_NewItemGlowEffect:GlowFilter;
		private var m_AvatarStats:AvatarStats;
		private var m_StoreUIState:Boolean = false;
		private var m_EditRoom:String = RealmConsts.ROOM_START;
		private var m_invItem:Boolean = false;
		private var m_Music:FlxSound;
		private var m_SfxConfirm:FlxSound;
		private var m_SfxCancel:FlxSound;
		
		public function RealmBuilder(room:String = RealmConsts.ROOM_START)
		{
			m_EditRoom = room;
			super();
		}
		
		override public function create():void 
		{
			super.create();

			m_Game = new RealmManager();
			m_AvatarStats = new AvatarStats();
			m_AvatarStats.addEventListener(RealmConsts.UPDATE_HEADER, onUpdateHeader);
			IsoMap.EditMode = true;
			m_Game.Stats = m_AvatarStats;
			m_Game.GameMode = GameModeConst.BUILDER;
			if (GameConstants.AVATAR_XML == "")
				m_Game.loadAvatarURL(Globals.RESOURCE_BASE + RealmConsts.AVATAR, true);
			else
				m_Game.loadAvatarXML(true);
			
			m_Game.SetStartRoom(m_EditRoom);
			m_Game.setRoomLoadCallback(onRoomLoadCallback);
			m_Game.EditMode = true;
			
			//see if the realm xml is cached
			if (Globals.REALM_XML == "") //get xml from the server
			{
				m_Game.loadRealmURL(Globals.RESOURCE_BASE + RealmConsts.REALM, true);
			}
			else //load the cache
			{
				m_Game.loadRealmXML(true);
			}
			
			//m_Game.loadAvatar("data/avatar.xml");
			m_PopupMenu = new ContextMenuManager(this);
			m_NewItemGlowEffect = new GlowFilter(0x00FDD017);
			m_NewItemGlowEffect.inner = true;
			
			//load realm builder store
			m_RealmStoreUILoader = new Loader();
			var mRequest:URLRequest = new URLRequest(Globals.RESOURCE_BASE + "/" + RealmConsts.UISwf + "RealmzBuilder.swf");
			m_RealmStoreUILoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteRealmStoreLoader);
			m_RealmStoreUILoader.load(mRequest);
			
			//Load Store
			m_StoreUILoader = new Loader();
			mRequest = new URLRequest(Globals.RESOURCE_BASE + "/" + RealmConsts.UISwf + "StoreFront.swf");
			m_StoreUILoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteStoreUILoader);
			m_StoreUILoader.load(mRequest);
			
			
			
			//setup up the message boxes
			initPopMsg();
			
			//background music	
			m_Music = new FlxSound();
			m_Music.loadStream(Globals.RESOURCE_BASE + "/assets/music/realm.mp3", true);
			m_Music.survive = false;
			m_Music.volume = 0.25;
			FlxG.music = m_Music;
			m_Music.fadeIn(8);
			
			m_SfxConfirm = new FlxSound();
			m_SfxConfirm.loadEmbedded(purchase_confirm, false);
			m_SfxCancel = new FlxSound();
			m_SfxCancel.loadEmbedded(purchase_cancel, false);
		}
		
		override public function destroy():void 
		{
			
			if (this.contains(m_HeaderMovieClip)) this.removeChild(m_HeaderMovieClip);
			if (this.contains(m_BuilderMovicClip)) this.removeChild(m_BuilderMovicClip);
			if (this.contains(m_StoreUIMovicClip)) this.removeChild(m_StoreUIMovicClip);//take store screen off the stage

			m_Music.stop();
			m_Music.destroy();
			m_Music = null;
			
			m_SfxConfirm.stop();
			m_SfxConfirm.destroy();
			m_SfxConfirm = null;
			m_SfxCancel.stop();
			m_SfxCancel.destroy();
			m_SfxCancel = null;
			
			removeEventListeners();
			m_BuilderMovicClip = null;
			m_HeaderMovieClip = null;
			m_StoreUIMovicClip = null;
			m_PopupMenu = null;
			m_Game.cleanUp();
			m_Game = null;
			m_NewItemGlowEffect = null;
			m_AvatarStats = null;
			super.destroy();			
		}
		
		private function onRoomLoadCallback():void {
			
			var _TempEvt:LoAUIEvent = new LoAUIEvent(LoAUIEvent.ITEM_TEMPLATE, true, false);
			_TempEvt.setStrData(String(m_Game.RealmObj.CurrentRoom.Template)); 
			this.dispatchEvent(_TempEvt);
		}
		
		private function onCompleteRealmStoreLoader(loadEvent:Event):void
		{
			m_BuilderMovicClip = loadEvent.currentTarget.content;
        	this.addChild(m_BuilderMovicClip);
			//clean up Loader memory
			m_RealmStoreUILoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteRealmStoreLoader);
			m_RealmStoreUILoader = null;
			//load the header
			m_HeaderUILoader = new Loader();
			var mRequest:URLRequest = new URLRequest(Globals.RESOURCE_BASE + "/" + RealmConsts.UISwf + "HeaderUI.swf");
			m_HeaderUILoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteUILoader);
			m_HeaderUILoader.load(mRequest);
		}

		private function onCompleteUILoader(loadEvent:Event):void
		{
			m_HeaderMovieClip = loadEvent.currentTarget.content;
        	this.addChild(m_HeaderMovieClip);
			//clean up loader memory
			m_HeaderUILoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteUILoader);
			m_HeaderUILoader = null;
			if (!m_UIInit) initUI();
		}
		
		private function onCompleteStoreUILoader(loadEvent:Event):void {
		
			m_StoreUIMovicClip = loadEvent.currentTarget.content;
			m_StoreUILoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteStoreUILoader);
			m_StoreUILoader = null;
		}
		
		private function onSwitchUI(evt:LoAUIEvent):void {
			
			if (evt.type == LoAUIEvent.UIHEADER_USERHOME) 
			{
				//switch to player home
				FlxG.state = new PlayerHome();
				//changing the state here is going to start freeing memory
				//have to exit now to avoid errors in the rest of the function
				return;
			}
			
			if (evt.type == LoAUIEvent.UIHEADER_MAP) 
			{
				//switch mode to the dungeon editor
				FlxG.state = new DungeonEditor();
				//changing the state here is going to start freeing memory
				//have to exit now to avoid errors in the rest of the function
				return; 
			}
			
			if (evt.type == LoAUIEvent.UIHEADER_BUYPOWER) 
			{
				this.addChild(m_StoreUIMovicClip);//put the char screen on the stage
				m_StoreUIState = true;
				//tell the Store screen to load
				var _StoreInitEvent:LoAUIEvent = new LoAUIEvent(LoAUIEvent.UI_ITEMURL, true, false);
				_StoreInitEvent.setStrData(Globals.RESOURCE_BASE); 
				this.dispatchEvent(_StoreInitEvent);			
					
				//the te store about the current stats
				if (m_AvatarStats)
				{
					if (XML(m_AvatarStats.toXMLString()).level > 0)
					{
						var _StatsEvnt:LoAUIEvent;
						_StatsEvnt = new LoAUIEvent(LoAUIEvent.UIHEADER_STATUPDATE, true, false);
						_StatsEvnt.setStrData(m_AvatarStats.toXMLString());
						//trace(m_AvatarStats.toXMLString());
						this.dispatchEvent(_StatsEvnt);
					}
				}
				
			}
			
			if (evt.type == LoAUIEvent.UIHEADER_STORECLOSE)
			{
				m_StoreUIState = false;
				if (this.contains(m_StoreUIMovicClip)) 
					this.removeChild(m_StoreUIMovicClip);
				m_Game.serverRequestStats();
			}
			
			if (evt.type == LoAUIEvent.UIHEADER_BUYBUCKS)
			{
				var result:Object = ExternalInterface.call("switchBuyBucksScreen");  
			}
			
		}
		
		private function initUI():void {
			
			m_UIInit = true;
			// send the UI an event with its URL included
			var _StoreURLEvt:LoAUIEvent = new LoAUIEvent(LoAUIEvent.UI_ITEMURL, true, false);
			_StoreURLEvt.setStrData(Globals.RESOURCE_BASE); 
			this.dispatchEvent(_StoreURLEvt);
			//tell the UI what templat is being used
			if ((m_Game.RealmObj != null) && (m_Game.RealmObj.CurrentRoom != null))
			{
				var _TempEvt:LoAUIEvent = new LoAUIEvent(LoAUIEvent.ITEM_TEMPLATE, true, false);
				_TempEvt.setStrData(String(m_Game.RealmObj.CurrentRoom.Template)); 
				this.dispatchEvent(_TempEvt);
			}
			
			// send the UI an event with the facebook access token
			var _HeaderTokenEvt:LoAUIEvent = new LoAUIEvent(LoAUIEvent.UIHEADER_ACCESSTOKEN, true, false);
			_HeaderTokenEvt.setStrData(Globals.ACCESSTOKEN); 
			this.dispatchEvent(_HeaderTokenEvt);
			
			//tell the header we are in build mode
			var _HeaderModeEvnt:LoAUIEvent = new LoAUIEvent(LoAUIEvent.UIHEADER_SWITCHMODE, true, false);
			_HeaderModeEvnt.setStrData(LoAUIEvent.UIHEADER_BUILDMODE); 
			this.dispatchEvent(_HeaderModeEvnt);
			
			if (m_AvatarStats)
			{
				if (XML(m_AvatarStats.toXMLString()).level > 0)
				{
					var _StatEvnt:LoAUIEvent;
					_StatEvnt = new LoAUIEvent(LoAUIEvent.UIHEADER_STATUPDATE, true, false);
					_StatEvnt.setStrData(m_AvatarStats.toXMLString());
					//trace(m_AvatarStats.toXMLString());
					this.dispatchEvent(_StatEvnt);
				}
			}
			
			//put the cursor on the stage last
			//this.addChild(m_Cursor);
		}
		
		private function initPopMsg():void {

			
		}
		
		public function onUpdateHeader(e:UpdateUIEvent):void {
			// send the update to the header ui to display
			var updateXML:XML = XML(e.Data);
			if (updateXML.level > 0)
			{
				var evnt:LoAUIEvent;
				evnt = new LoAUIEvent(LoAUIEvent.UIHEADER_STATUPDATE, true, false);
				evnt.setStrData(e.Data);
				dispatchEvent(evnt);
			}
		}
		
		override public function update():void
        {
			super.update();
			if (m_Music != null) m_Music.update();
			m_Game.updateBeforeRender();
		}
		
		override public function render():void
		{
			super.render();
			
			m_Game.render(0);//background
			m_Game.render(1);//floor
			m_Game.render(2);//life area
			if (m_PopupMenu != null)
				m_PopupMenu.render();
			m_Game.render(3);//Lights
			//render UI?
			m_Game.updateAfterRender();	
			m_Game.MessageBoxManager.render();
		}
		
		override protected function removeEventListeners():void
		{
			FlxG.state.parent.stage.removeEventListener(MouseEvent.CLICK, onClick);
			FlxG.state.parent.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			FlxG.state.parent.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.ITEM_PICKUP, onUIItemPickup);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.ITEM_CANCEL, onCancelChanges);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.ITEM_COMMIT, onCommitChanges);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.UIHEADER_USERHOME, onSwitchUI);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.UIHEADER_MAP, onSwitchUI);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.UIHEADER_BUYPOWER, onSwitchUI);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.UIHEADER_STORECLOSE, onSwitchUI);
			FlxG.state.parent.stage.removeEventListener(LoAUIEvent.UIHEADER_BUYBUCKS, onSwitchUI);
		}
		
		override protected function assignEventListeners():void 
		{
			FlxG.state.parent.stage.addEventListener(MouseEvent.CLICK, onClick);
			FlxG.state.parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			FlxG.state.parent.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.ITEM_PICKUP, onUIItemPickup);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.ITEM_CANCEL, onCancelChanges);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.ITEM_COMMIT, onCommitChanges);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.UIHEADER_USERHOME, onSwitchUI);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.UIHEADER_MAP, onSwitchUI);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.UIHEADER_BUYPOWER, onSwitchUI);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.UIHEADER_STORECLOSE, onSwitchUI);
			FlxG.state.parent.stage.addEventListener(LoAUIEvent.UIHEADER_BUYBUCKS, onSwitchUI);
			
		}
		
		private function onClick(e:MouseEvent):void {

			if (e.target is SimpleButton) return;
			if (e.target is MovieClip) return;
			if (e.target is Loader) return;
			ToolTips.hide();
			if (m_Game.MessageBoxManager.MouseClick(e.stageX, e.stageY)) return;
			if (m_PopupMenu.MouseClick(e.stageX, e.stageY)) return;
			//m_Game.onClickEditMode(e.stageX, e.stageY);
			m_Game.onClick(e.stageX, e.stageY);
			
		}  
		
		private function onUIItemPickup(evt:LoAUIEvent):void
		{
			//trace("Received ITEM_PICKUP event: " + evt);
			// we want to make a copy of the store object and attach it to the mouse
			var _mouseItem:LoAItem = evt.getLoAItem();
			var url:String = Globals.RESOURCE_BASE + RealmConsts.ITEMS +_mouseItem.Type + "&id=" + _mouseItem.ItemID;
			//trace(url);
			var xmlLoader:URLLoader = new URLLoader();
			ToolTips.hide();
			//trace("Item:" + _mouseItem.ItemName + "\n  UnCommited :" + _mouseItem.Uncommitted);
			m_invItem = !_mouseItem.Uncommitted;
			
			//get rid of any pending purchase requests
			var _CancelEvnt:LoAUIEvent;
			_CancelEvnt = new LoAUIEvent(LoAUIEvent.REMOVE_DIALOG, true, false);
			this.dispatchEvent(_CancelEvnt);
			m_Game.cancelMoveItem();
			
			xmlLoader.addEventListener(Event.COMPLETE, onItemLoad);
			xmlLoader.load(new URLRequest(url));	
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			if(event.keyCode == 27) 
			{
				m_Game.cancelMoveItem();
			}
	
		}
		private function onMouseMove(e:MouseEvent):void {
			
			//trace(e.target);
			if (e.target is SimpleButton) return;
			if (e.target is MovieClip) return;
			if (e.target is Loader) return;
			if (m_Game == null) return;
			if (m_PopupMenu == null) return;
			
			if (m_Game.MessageBoxManager.MouseMove(FlxG.mouse.x, FlxG.mouse.y)) return;
			if (m_PopupMenu.MouseOver(FlxG.mouse.x, FlxG.mouse.y)) return;
			
			
			m_Game.onMouseMoveEditMode(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		private function onItemLoad(e:Event):void
		{
			if (m_Game.ItemBeingDragged != null) return;
			
			var xml:XML = XML(e.target.data);
			//trace(xml);
			//cancel pendning
			if (m_Game.NewItem != null)
			{
				m_Game.removeItem(m_Game.NewItem, false);
				m_Game.NewItem = null;
			}
			
			if (RealmManager(m_Game).checkPendingMapStructure() != null)
				RealmManager(m_Game).cancelPendingMapStructure();
				
			//add new item
			if (m_Game.NewItem == null && RealmManager(m_Game).checkPendingMapStructure() == null)
			{//only load a new item if one is not being dragged
				var item:GameObject = null;
				var count:int = 0;
				
				if (int(xml.dataset.Monsters.monster.property.@type) > 0)
				{//determin if the max level of monsters for this room is reached or not
					//Count the mosnters
					count = m_Game.getMonsterCount();
					switch (m_Game.RealmObj.MonsterLevel)
					{
						case 0://2 monsters per room
							if (count < 2)
								item = m_Game.loadEditorItem(xml);	
							break;
						case 1://3 monsters in 8x8 and up
							if (m_Game.RealmObj.CurrentRoom.Template < 4 && count < 3)
								item = m_Game.loadEditorItem(xml);	
							else//not in 8x8 or greater
								if (count < 2)
									item = m_Game.loadEditorItem(xml);		
							break;
						case 2://4 monsters in 10x10 and up
							if ((m_Game.RealmObj.CurrentRoom.Template == 1 || m_Game.RealmObj.CurrentRoom.Template == 3) && count < 4)
								item = m_Game.loadEditorItem(xml);	
							else//not in 10x10 or greater
								if (m_Game.RealmObj.CurrentRoom.Template < 4 && count < 3)
									item = m_Game.loadEditorItem(xml);	
								else//not in 8x8 or greater
									if (count < 2)
										item = m_Game.loadEditorItem(xml);		
							break;
						case 3://5 monsters in 12x12
							if (m_Game.RealmObj.CurrentRoom.Template == 1 && count < 5)
									item = m_Game.loadEditorItem(xml);	
							else//not in 12x12
								if (m_Game.RealmObj.CurrentRoom.Template == 3 && count < 4)
									item = m_Game.loadEditorItem(xml);	
								else//not in 10x10 or greater
									if (m_Game.RealmObj.CurrentRoom.Template < 4 && count < 3)
										item = m_Game.loadEditorItem(xml);	
									else//not in 8x8 or greater
										if (count < 2)
											item = m_Game.loadEditorItem(xml);	
							break;
					}
					if(item == null)//didnt get an item probably max reached
						MsgBoxManager.staticShowMessage(MsgConstants.MAX_MONSTER);
				}else
					if (int(xml.dataset.Traps.trap.property.@type) > 0)
					{//determin if the max level of traps for this room is reached or not
						//count traps
						count = m_Game.getTrapCount(); 
						switch (m_Game.RealmObj.TrapLevel)
						{
							case 0://0 traps per room
								break;
							case 1://1 trap per room
								if (count < 1)
									item = m_Game.loadEditorItem(xml);		
								break;
							case 2://2 traps in 10x10 and up
								if ((m_Game.RealmObj.CurrentRoom.Template == 1 || m_Game.RealmObj.CurrentRoom.Template == 3) && count < 2)
									item = m_Game.loadEditorItem(xml);	
								else//not in 10x10 or greater
									if (count < 1)
										item = m_Game.loadEditorItem(xml);	
								break;
							case 3://3 traps in 12x12
								if (m_Game.RealmObj.CurrentRoom.Template == 1 && count < 3)
									item = m_Game.loadEditorItem(xml);	
								else//not in 12x12
									if (m_Game.RealmObj.CurrentRoom.Template == 3 && count < 2)
										item = m_Game.loadEditorItem(xml);	
									else//not in 10x10 or greater
										if (count < 1)
											item = m_Game.loadEditorItem(xml);	
								break;
						}
						if(item == null)//didnt get an item probably max reached
							MsgBoxManager.staticShowMessage(MsgConstants.MAX_TRAP);
						
					}else//just load whatever
						item = m_Game.loadEditorItem(xml);
				
				var _Evnt:LoAUIEvent;
				
				if (item)
				{
					_Evnt = new LoAUIEvent(LoAUIEvent.REMOVE_LOADING, true, false);
					this.dispatchEvent(_Evnt);
					
					if (!m_invItem)
					{//not loading from inventory
						item.NewItem = true;
						item.addGlowEffect(m_NewItemGlowEffect);
						m_Game.NewItem = item;
						if (item.CoinCost > 0)
						{
							_Evnt = new LoAUIEvent(LoAUIEvent.REMOVE_DIALOG, true, false);
							this.dispatchEvent(_Evnt);
						}
					}else
					{//loading from the inventory
						item.InvItem = true;
						RealmManager(m_Game).addItem(item);
					}
					m_Game.moveItem(item);
					
					m_invItem = false;
					
				}else
				{//didnt load the item so clean up
					_Evnt = new LoAUIEvent(LoAUIEvent.REMOVE_LOADING, true, false);
					this.dispatchEvent(_Evnt);
					_Evnt = new LoAUIEvent(LoAUIEvent.REMOVE_DIALOG, true, false);
					this.dispatchEvent(_Evnt);
					if (RealmManager(m_Game).checkPendingMapStructure() != null)
					{
						m_SfxConfirm.play();
						RealmManager(m_Game).buyMapStructure();
						RealmManager(m_Game).showPurchaseStruct();
					}

				}
			}	
		}
		
		
		private function onCommitChanges(e:Event):void
		{
			m_SfxConfirm.play();
			if (m_Game.NewItem != null)
			{
				RealmManager(m_Game).buyItem(); 
			}else 
				RealmManager(m_Game).buyMapStructure();
		}
		
		private function onCancelChanges(e:Event):void
		{
			m_SfxCancel.play();
			m_Game.cancelMoveItem();
			if (m_Game.NewItem != null)
			{
				m_Game.removeItem(m_Game.NewItem, false);
				m_Game.cancelNewItem();
			}else
				RealmManager(m_Game).cancelPendingMapStructure();
		}
		
		
		
	}

}