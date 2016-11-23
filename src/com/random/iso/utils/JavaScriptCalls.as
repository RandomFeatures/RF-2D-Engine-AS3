package com.random.iso.utils 
{
	/**
	 * ...
	 * @author Allen Halsted
	 */
	public class JavaScriptCalls
	{
		
		public function JavaScriptCalls() 
		{
			
		}
		public static function launchURL(param1:String, param2:String = "_blank", param3:Object = null, param4:Boolean = false) : void
        {
            var browser:String;
            var url:* = param1;
            var target:* = param2;
            var variables:* = param3;
            var useJS:* = param4;
            var request:* = new URLRequest(url);
            var useNavigateToURL:Boolean;
            if (variables)
            {
                request.data = variables;
            }
            try
            {
                if (ExternalInterface.available)
                {
                    browser = ExternalInterface.call("function a() {return navigator.userAgent;}");
                    if (browser != null && browser.indexOf("Firefox") < 1)
                    {
                        useNavigateToURL;
                    }
                    else
                    {
                        ExternalInterface.call("window.open", url, target, "");
                        useNavigateToURL;
                    }
                }
                else
                {
                    useNavigateToURL;
                }
            }
            catch (error:SecurityError)
            {
                useNavigateToURL;
            }
            if (useNavigateToURL)
            {
                if (useJS)
                {
                    ExternalInterface.call("window.open", url, target, "");
                }
                else
                {
                    navigateToURL(request, target);
                }
            }
            return;
        }// end function
	}

}