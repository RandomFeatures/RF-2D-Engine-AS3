package com.random.game.consts 
{
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class StaticResources
	{
		
		//[Embed(source = "../../assets/Adventure.ttf", fontFamily = "adventure")] 
		//protected var FontAdventure:String;
		
		[Embed(source='../../../../../assets/background.jpg')]
        public static var MapBG:Class;
		
		[Embed(source='../../../../../assets/btnPublish.png')]
		public static const ImageButtonPublish:Class;

		[Embed(source='../../../../../assets/btnSkip.png')]
		public static const ImageButtonSkip:Class;
		
		[Embed(source='../../../../../assets/btnNoThanks.png')]
		public static const ImageButtonNotThans:Class;

		[Embed(source='../../../../../assets/btnNotNow.png')]
		public static const ImageButtonNotNow:Class;

		//[Embed(source='../../assets/SkipUp.png')]
		//public static const ImageButtonSkip:Class;
		
		[Embed(source='../../../../../assets/pop_up_window.png')]
		public static const ImageBackGroundPopup:Class;
		
		[Embed(source='../../../../../assets/btnOk.png')]
		public static const ImageButtonOk:Class;
		
		[Embed(source='../../../../../assets/btnNext.png')]
		public static const ImageButtonNext:Class;
		
		[Embed(source='../../../../../assets/cursor.png')]
        public static const ImageCursor:Class;

		[Embed(source='../../../../../assets/redArrow.png')]
        public static const RedArrow:Class;

		[Embed(source='../../../../../assets/single_coin.png')]
        public static const OneCoin:Class;

		[Embed(source='../../../../../assets/double_coin.png')]
        public static const TwoCoins:Class;
		
		[Embed(source='../../../../../assets/triple_coin.png')]
        public static const ThreeCoins:Class;

		[Embed(source='../../../../../assets/six_coin.png')]
        public static const SixCoins:Class;
		
	}

}