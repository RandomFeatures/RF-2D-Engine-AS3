package com.random.game.state 
{
	import com.random.iso.GameState;
	import com.random.game.objmanager.AdventureManager;
	import org.flixel.FlxG;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import com.random.game.consts.RealmConsts;
	import com.random.game.AvatarStats;
	import com.random.game.events.UpdateUIEvent;
	import flash.filters.GlowFilter
	import com.random.iso.consts.IsoConstants;
	import com.random.iso.characters.monsters.MonsterAction;
	import com.random.iso.items.DoorObject;
	import com.random.iso.items.TrapObject;
	import com.random.iso.consts.MsgConstants;
	import org.flixel.FlxSound;
	import com.random.iso.consts.GameConstants;
	import com.random.game.consts.GameModeConst;
	import flash.display.SimpleButton;
	import com.random.game.UI.MsgBoxManager;
	import com.random.game.consts.Globals;
	import flash.external.ExternalInterface;
	import com.random.game.RealmState;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	
	public class Adventure extends RealmState
	{
		
		 /**
         * @private
         * legal tile
         */
		private var m_CharUIState:Boolean = false;
		private var m_StoreUIState:Boolean = false;
		private var m_UIInit:Boolean = false;
		private var m_AvatarStats:AvatarStats;
		private var m_Music:FlxSound;
		
		public function Adventure()
		{
			super();
		}
		
		override public function create():void 
		{
			
			super.create();
		
			m_Game = new AdventureManager();
			MonsterAction.m_GlowEffect = new GlowFilter(0x00FF0000);
			DoorObject.m_GlowEffect = new GlowFilter(0x00FF0000);
			TrapObject.RenderLayer = 3;
			
			m_AvatarStats = new AvatarStats();
			m_Game.Stats = m_AvatarStats;
			m_Game.GameMode = GameModeConst.ADVENTURE;
			m_Game.SetStartRoom(RealmConsts.ROOM_START);
			m_Game.EditMode = false;

			m_Game.loadRealmURL(Globals.RESOURCE_BASE+RealmConsts.FINDADVENTURE, true);
			
			//see of the avatar xml is cached
			if (GameConstants.AVATAR_XML == "")//get new avatar from the server
				m_Game.loadAvatarURL(Globals.RESOURCE_BASE + RealmConsts.AVATAR, false);
			else//load cached xml
				m_Game.loadAvatarXML(false);
			
			
			
			//setup up the message boxes
			initPopMsg();
			//play background m usci
			m_Music = new FlxSound();
			m_Music.loadStream(Globals.RESOURCE_BASE + "/assets/music/adventure.mp3", true);
			m_Music.survive = false;
			m_Music.volume = 0.25;
			FlxG.music = m_Music;
			m_Music.fadeIn(8);
			
			if (!m_UIInit) initUI();

		}

			
		
		private function initUI():void {
			
			m_UIInit = true;
			
			
			if (m_AvatarStats)
			{
				if (XML(m_AvatarStats.toXMLString()).level > 0)
				{
				}
			}
			
		}
		
		private function initPopMsg():void {

			
		}
		
		override public function destroy():void 
		{
			m_Music.stop();
			m_Music.destroy();
			m_Music = null;
			removeEventListeners();
			m_Game.cleanUp();
			m_Game = null;
			m_AvatarStats = null;
			super.destroy();
		}
		
		override public function update():void
        {
			super.update();
			
			if (m_Music != null) m_Music.update();
			m_Game.updateBeforeRender();
		}
		
		override public function render():void
		{
			if (m_Game == null) return;
			super.render();
		
			m_Game.render(0);//background
			m_Game.render(1);//floor
			m_Game.render(2);//life area
			m_Game.render(3);//Lights
			//render UI?
			m_Game.updateAfterRender();	
			if(m_Game.MessageBoxManager != null)
				m_Game.MessageBoxManager.render();

		}
		
		override protected function assignEventListeners():void 
		{
			FlxG.state.parent.stage.addEventListener(MouseEvent.CLICK, onClick);
			FlxG.state.parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	
		}
		
		override protected function removeEventListeners():void
		{
			FlxG.state.parent.stage.removeEventListener(MouseEvent.CLICK, onClick);
			FlxG.state.parent.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		
		private function onClick(e:MouseEvent):void {
			if (e.target is SimpleButton) return;
			if (m_CharUIState || m_StoreUIState) return;
			if (m_Game.MessageBoxManager.MouseClick(e.stageX, e.stageY)) return;
			m_Game.onClick(e.stageX, e.stageY);
		}  
		
		private function onMouseMove(e:MouseEvent):void {
			
			if (e.target is MovieClip) return;
			if (e.target is Loader) return;
			if (e.target is SimpleButton) return;
			if (m_Game.MessageBoxManager.MouseMove(FlxG.mouse.x, FlxG.mouse.y)) return;
			if (m_CharUIState || m_StoreUIState) return;
			
			
			m_Game.onMouseMove(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		
	}

}