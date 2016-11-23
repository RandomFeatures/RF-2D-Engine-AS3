package com.random.game.UI 
{
	
	import com.random.iso.characters.avatar.LayerCharacter;
	import com.random.iso.ui.InformationBox;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import com.random.iso.ui.MessageBox;
	import com.random.iso.ui.QuestionBox;
	import com.random.iso.consts.MsgConstants;
	import com.random.game.consts.StaticResources;
	import com.random.game.consts.RealmConsts;
	import de.polygonal.ds.ArrayedQueue;
	import flash.utils.Timer;
	import org.flixel.FlxG;
	import com.random.game.state.Adventure;
	import org.flixel.FlxSound;
	import com.random.iso.ui.ToolTips;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class MsgBoxManager
	{
		
		private static var m_MsgQueue:ArrayedQueue;
		private static var m_ActiveMessage:MessageBox;
		
		
		public function MsgBoxManager() 
		{
			
			
		}
		
		public function get Visible():Boolean 
		{ 
			return false;
		}
		
		public static function isActive():Boolean {
			return false;
		}
		
		
		public function render():void {
			
		
		}

		public function hideAll():void {
			
		
		}
		
		public function destroy():void {
			
		
		}
		
		private function checkQueueTimer(e:TimerEvent):void 
		{
			
			
		}
		
		public function MouseClick(x:int, y:int):Boolean {
			
			return false;
		}
		public function MouseMove(x:int, y:int):Boolean {
		return false;
		}
		
	

		
		
		public function staticShowMessage(msg:String):void {
		
		}
		
		public function showMessageBox(msg:String):void {
		}
		
		public function showHelpMessageBox(msg:String, x:int, y:int, rot:Number, bAnimate:Boolean=false):void {
		
		}
		
	
		
		public function showConverseMsg(msg:String):void {
		
		}
		
		
		public function showConverseHelpMsg(msg:String, x:int, y:int, rot:Number, bAnimate:Boolean=false):void {
		
		}
		
		public function showPublishedMsg():void {
			
			
		}
		
		public function showPublishedHelpMsg(msg:String, x:int, y:int, rot:Number, bAnimate:Boolean = false):void {
			
		}
		
	
		
		public  function showLostConnection():void {
			
			
		}
	
		public function showLevelupMsg():void {
		
		}
		
	
		public function showLoadAdventure(onLoadAdventure:Function):void {
			
		}
		
		
		public function showPlayerBuyPotion():void {
		
		}
		
	
		
	
		
		public function showOpenMasterChest(gold:int):void
		{
			
		}
		
	
		
		public function showWelcome():void {
		
			
		}
		
		
		public function showBuyBuckBroke():void {
		
		}
		
		public function showBuyBucksBeforeAdventure():void {
			
		}

		
		
		
		public function showTooWeekToAdventure():void {
			
		}

		public function showPlayerDefeat():void {
			
		}
		
		
		
		
		
		public function showIgorLeave():void {
		
		}
		
		public function InviteFriend():void {
			
		}
			
		
		
		
	}

}