package com.random.iso.utils 
{
	import flash.net.SharedObject;
	import Date;
	/**
	 * ...
	 * @author Allen Halsted
	 */
	class flashCookie {

		 private var so:SharedObject;

		 function flashCookie() {
			  //empty
		 }
		
		 //set cookie with the current date and time
		 public function setCookie(cName:String,cData:Object):Void {	
			  var date:Date = new Date();
			  so = SharedObject.getLocal(cName);
			  so.data.cookie_name = cName;
			  so.data.cookie_created = date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " - " + date.getDate() + "/" + (date.getMonth() + 1) + "/" + date.getFullYear();
			  so.data.cookie_data = cData;
			  so.flush();	
		 }

		 //retrieve the cookie if it exists
		 public function readCookie(cName:String):Object {	
			  so = SharedObject.getLocal(cName);
			  if (so.data.cookie_name == cName) {
				   return so.data.cookie_data;
			  }	
			  return false;		
		 }

		 //delete the cookie
		 public function deleteCookie(cName:String):Void {	
			  so = SharedObject.getLocal(cName);
			  if (so.data.cookie_name == cName) {
				   so.clear();
			  }		
		 }
	}
}