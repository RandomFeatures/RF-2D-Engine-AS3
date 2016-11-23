package com.random.game
{
	import com.random.iso.GameState;
	import com.random.game.MyRealmObjManager;
	//import UI.Cursor;
	import flash.display.Bitmap;
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import com.random.game.consts.StaticResources;
	import flash.ui.Mouse;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class RealmState extends GameState
	{
		/*
		[Embed(source = "../assets/Adventure.ttf", fontFamily = "adventure")] 
		protected var junks:String;
		
		[Embed(source='../assets/PublishUp.png')]
		protected static var ButtonPublish:Class;

		[Embed(source='../assets/SkipUp.png')]
		protected static var ButtonSkip:Class;
		
		[Embed(source='../assets/pop_up_window.png')]
		protected static var PopupBG:Class;
		
		//[Embed(source='../assets/igor.png')]
		//protected static var PopupIcon:Class;

		[Embed(source='../assets/OkUp.png')]
		protected static var PopupOkButton:Class;
		
		[Embed(source='../assets/cursor.png')]
        protected static var CursorClass:Class;
*/
		protected var m_Game:MyRealmObjManager;
		//protected var m_Cursor:Cursor;
		//protected var cursor:Bitmap;
		
		public function RealmState() 
		{
			super();
		}
		
		override public function create():void 
		{
			//m_Cursor = new Cursor(FlxG.state.parent.stage);
			//cursor = new StaticResources.ImageCursor();
			//cursor.height = 32;
			//cursor.width = 32;
			//m_Cursor.addChild(cursor);
			Mouse.show();
			FlxState.bgColor = 0xff4d7398;
		}
		
		override public function destroy():void 
		{
			//m_Cursor = null;
		}
		
		public function get GameObjManager():MyRealmObjManager { return m_Game; }
		

	}

}