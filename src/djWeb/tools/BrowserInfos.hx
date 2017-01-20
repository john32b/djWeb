package djWeb.tools;
import js.Browser;
import js.html.Document;
import js.html.VideoElement;

/**
 * Browser infos
 */
class BrowserInfos
{	
	public var IS_MOBILE(default, null):Bool;
	public var IS_WEBKIT(default, null):Bool; // Chrome, Edge, new Opera?
	public var VIDEO_WEBM(default, null):Bool;
	public var VIDEO_MP4(default, null):Bool;
	public var SUPPORT_XMLREQUEST(default, null):Bool;
	
	//---------------------------------------------------;
	
	public function new() 
	{ 
		checkAll();
	}//---------------------------------------------------;
	
	/**
	 * Checks all but not for video,check it manually
	 */
	public function checkAll()
	{
		IS_WEBKIT = untyped __js__("'WebkitAppearance' in document.documentElement.style");
		IS_MOBILE = isMobile();
		SUPPORT_XMLREQUEST = untyped __js__ ("typeof XMLHttpRequest != 'undefined'");
		
		// -- info  --
		trace("BROWSER.IS_WEBKIT", IS_WEBKIT);
		trace("BROWSER.IS_MOBILE", IS_MOBILE);
		trace("BROWSER.SUPPORT_XMLREQUEST", SUPPORT_XMLREQUEST);
	}//---------------------------------------------------;
	
	
	/**
	 * Checks video capability
	 */
	public function videoCheck()
	{
		var vid:VideoElement = untyped W.dom.newElement("video");
		
		VIDEO_WEBM = vid.canPlayType('video/webm; codecs="vp8, vorbis"') != "";
		VIDEO_MP4  = vid.canPlayType('video/mp4; codecs="mp4v.20.8"') != "";

		trace("BROWSER.VIDEO_WEBM", VIDEO_WEBM);
		trace("BROWSER.VIDEO_MP4", VIDEO_MP4);
	}//---------------------------------------------------;

	// -- 
	function isMobile():Bool
	{
		 return ( 	   
		(Browser.navigator.userAgent.indexOf('Android') >= 0 && Browser.navigator.userAgent.indexOf('Mobile') >= 0)
		|| Browser.navigator.userAgent.indexOf('webOS') >= 0
		|| Browser.navigator.userAgent.indexOf('iPhone') >= 0
		|| Browser.navigator.userAgent.indexOf('iPod') >= 0
		|| Browser.navigator.userAgent.indexOf('BlackBerry') >= 0
		|| Browser.navigator.userAgent.indexOf('Windows Phone') >= 0
		//|| Browser.navigator.userAgent.indexOf('iPad') >= 0 // Note: No IPAD, it is big and counts as desktop view.
		);
		
		// Other way of doing it (via stackoverflow)
		//  var isMobile = window.matchMedia("only screen and (max-width: 760px)");
	}//---------------------------------------------------;
	
}// --