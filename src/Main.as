package 
{
	import com.random.iso.GameController;
	import flash.utils.Timer;
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	import com.random.game.state.RealmBuilder;
	import com.random.game.state.Adventure;
	import com.random.iso.consts.GameConstants;
	import com.random.game.consts.RealmConsts;
	import com.random.game.consts.Globals;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class Main extends GameController 
	{
		
		public function Main():void 
		{
			super(GameConstants.SCREENWIDTH, GameConstants.SCREENHEIGHT, Adventure, 1); 
		}
		
	}
	
}