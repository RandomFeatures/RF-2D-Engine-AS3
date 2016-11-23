package 
{
	import com.random.iso.GameController;
	import flash.utils.Timer;
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	import state.RealmBuilder;
	import state.Adventure;
	import state.PlayerHome;
	import state.DungeonEditor;
	import state.Splash;
	import com.random.iso.consts.GameConstants;
	import consts.RealmConsts;
	import consts.GlobalTimer;
	import consts.Globals;
	import flash.system.Security;
	
	[SWF(width = "760", height = "640", backgroundColor = "#4d7398")] //Set the size and color of the Flash file

	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class Main extends GameController
	{
		
		public function Main()
		{
			var realm:Class = Splash;
			
			//trace(this.root.loaderInfo.parameters.baseurl);
			
			if (this.root.loaderInfo.parameters.baseurl != null)
			{
				Globals.RESOURCE_BASE = this.root.loaderInfo.parameters.baseurl;
				GameConstants.RESOURCE_BASE = this.root.loaderInfo.parameters.baseurl;
			}
			
			if (this.root.loaderInfo.parameters.friendrealm != null)
			{
				Globals.LOADADVENTURE = this.root.loaderInfo.parameters.friendrealm;
				//FlxG.log(RealmConsts.LOADADVENTURE);
			}
			
			if (this.root.loaderInfo.parameters.tokenid != null)
			{
				Globals.ACCESSTOKEN = this.root.loaderInfo.parameters.tokenid;
			}
			
			
			if (this.root.loaderInfo.parameters.start != null)
			{
				Globals.STARTTYPE = this.root.loaderInfo.parameters.start;
			}
			/*
			if (this.root.loaderInfo.parameters.type == "adv")
				realm = Adventure; 
			else if (this.root.loaderInfo.parameters.type == "relm")
				realm = RealmBuilder;
			else if (this.root.loaderInfo.parameters.type == "hom")
				realm = PlayerHome;
			else if (this.root.loaderInfo.parameters.type == "dun")
				realm = DungeonEditor;
			else if (this.root.loaderInfo.parameters.type == "splash")
				realm = Splash;				
			*/
			//StatTimer._Timer = new Timer(31000);	//31 seconds
			GlobalTimer._OneSecondTimer = new Timer(1000);	//2.5 min
			GlobalTimer._OneSecondTimer.start();
			super(GameConstants.SCREENWIDTH, GameConstants.SCREENHEIGHT, realm, 1); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
			//super(GameConstants.SCREENWIDTH, GameConstants.SCREENHEIGHT, realm, 1); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
			
		}
		
		
	}
}