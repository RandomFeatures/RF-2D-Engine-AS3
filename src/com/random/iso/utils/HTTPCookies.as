package com.random.iso.utils 
{
	import flash.external.ExternalInterface;

	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class HTTPCookies
	{
		
	    public static function getCookie(key:String):*
		{
			return ExternalInterface.call("getCookie", key);
		}

		public static function setCookie(key:String, val:*):void
		{
			ExternalInterface.call("setCookie", key, val);
		}

	}

}