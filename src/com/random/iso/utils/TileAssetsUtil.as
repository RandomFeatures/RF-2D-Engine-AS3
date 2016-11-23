package com.random.iso.utils {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    
    /**
     * Holds references to the various tile images that the game uses
	 * ..
     * @author Allen Halsted
     */
    public class TileAssetsUtil {

        
        /**
         * @private
         * legal tile
         */
        [Embed(source='../../../../../assets/tiles/basetile.png')]
        private static var LegalTileBitmap:Class;
        
        /**
         * @private
         * illegal tile
         */
        [Embed(source='../../../../../assets/tiles/redtile.png')]
        private static var IllegalTileBitmap:Class;
        
		/**
         * @private
         * threat radious tile
         */
        [Embed(source='../../../../../assets/tiles/yellowtile.png')]
        private static var ThreatTileBitmap:Class;
        
		/**
         * @private
         * Blocked tile
         */
        [Embed(source='../../../../../assets/tiles/greytile.png')]
        private static var BlockedTileBitmap:Class;
		
		
		
		/**
         * This constant represents a legal tile in user
         * homes.
         */
        public static const LEGAL_TILE_DATA:BitmapData = Bitmap(new LegalTileBitmap()).bitmapData;
        
        /**
         * This constant represents an illegal tile in user
         * homes.
         */
        public static const ILLEGAL_TILE_DATA:BitmapData = Bitmap(new IllegalTileBitmap()).bitmapData;
        
		
		/**
         * This constant represents an illegal tile in user
         * homes.
         */
        public static const THREAT_TILE_DATA:BitmapData = Bitmap(new ThreatTileBitmap()).bitmapData;
		
		/**
         * This constant represents an illegal tile in user
         * homes.
         */
        public static const BLOCKED_TILE_DATA:BitmapData = Bitmap(new BlockedTileBitmap()).bitmapData;

    }
	
    
}