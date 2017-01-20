package djWeb;
import djWeb.other.FixedHeader;
import djWeb.tools.Helper;
import haxe.Log;
import haxe.PosInfos;
import js.Browser;
import js.html.Element;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import haxe.Timer;

/**
 * Override this class and set the child as the document start
 * for customization check the "defaultParams" and set overrides with super({..});
 * ...
 * NOTES:
 * 	
 */
class MainFrame
{
	
	// First run Parameters
	// Override on Child before SUPER()
	static var defaultParams:Dynamic = { 
		
		scrollable:false,		// Allow the main container to be scrollable on Y axis
		scrollEvents:false,		// Allow firing events on scroll, disable to speed things up a bit?
		scrollCheckFreq:150,	// If scrollevents, check for new elements every XXX milisecs. Buffering for smoothing.
		
		pageTitle:"djWeb framework",
		
		staticBG:false,			// If true, the BG will not scroll
	};
	
	//====================================================;
	
	// Hold the current working run parameters
	private var params:Dynamic;
	
	/**
	 * The MAIN container where everything is added to.
	 */
	public var el(default, null):Element;
	
	/**
	 * If it's a static BG then it's a new elemnet, else it's 
	 * a pointer to the main element
	 */
	public var bg(default, null):Element;
		
	/**
	 * # CURRENTLY UNUSED #  <-----------------
	 * Optional Overlay, Stays on top, like a modal.
	 */
	public var overlay:Element;
	
	/**
	 * Full frame width, same as window inner width
	 */
	public var width(default,null):Int;
	/**
	 * Full frame height, same as window inner height
	 */
	public var height(default, null):Int;
	
	
	// -- SCROLL EVENTS VARIABLES --
	public var scroll_top(default,null):Int;		// Current scroll ammount from the top
	public var scroll_bottom(default, null):Int; 	// Current scroll ammount where the page ends
	public var scroll_prev(default, null):Int;		// The previous scroll value, used to calculate a delta
		   var _scrollCheckLock:Bool;				// Buffer scrolling checks to save CPU, False=Allowed to check
		   
	
	// -- VISIBILITY PARAMETERS
	// -- Meaning, if the tab is active/visible or not
	// From: https://developer.mozilla.org/en-US/docs/Web/API/Page_Visibility_API
	public var isVisible(default, null):Bool;
			var _v_hidden:String;
			var _v_change:String;
	
	// Is the webpage currently focused or not.
	public var isFocused(default, null):Bool;
	
	// !! MOBILE ONLY !!
	// TRUE for portrait, FALSE for landscape
	public var isPortrait(default, null):Bool;
	
	// -- Header
	// -- If a header is set, then it's visible at all times
	public var header:FixedHeader = null;
	
	
	// -- Pages
	// -- Pointer to the current page
	// - Crate an empty page now, so that it can never be Null
	public var currentPage(default, null):Page = new Page('default');
	
	// -- Map pages to string ID
	public var pages(default, null):Map<String,Page>;
	
	//====================================================;
	
	/**
	 * Create the main page
	 * 
	 * @param	params Check the static var "defaultParams" for help.
	 */
	public function new(?p_:Dynamic) 
	{		
		this.params = Helper.defParams(p_, defaultParams);
		W.init();
		W.main = this;
		
		Browser.document.title = params.pageTitle;

		// -- Create the main container first thing
		createContainer();
		
		// -- Mobile
		if (W.browser.IS_MOBILE)
		{
			// Is mobile, add specific meta tags
			W.dom.ADD_META('viewport', "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no");
			// 	<meta name="viewport" content="initial-scale=1 maximum-scale=1 user-scalable=0 minimal-ui shrink-to-fit=no" />

			// Add orientation Listener
			Browser.window.addEventListener('orientationchange', onOrientationChange);
			onOrientationChange();
		}

		// -- Make a default page , created at var declaration
		pages = new Map();
		addPage(currentPage);
		el.appendChild(currentPage.el);
		
		// # LISTENERS ---- ::
		
		// - Resize Listener
		Browser.window.onresize = onResize;
		onResize();  // Get the first width and heights
		
		// -- Add scroll Listener
		scroll_top = 0;
		
		if (params.scrollEvents && params.scrollable)
		{
			trace("+ Adding Event Listener, onScroll()");
			Browser.window.onscroll = __onScroll;
			_scrollCheckLock = false; // Allowed to check
			
			onScroll(); // Force an initial scroll_vars calculations
		}
		
		// -- Focus, Blur Listener
		Browser.window.onfocus = onFocus;
		Browser.window.onblur = onBlur;
		isFocused = Browser.document.hasFocus();
		// -- 
		
		// -- Visibility Listener
		if (untyped __js__('typeof document.hidden !== "undefined"'))
		{
			_v_hidden = "hidden";
			_v_change = "visibilitychange";
		}else
		if (untyped __js__('typeof document.msHidden !== "undefined"'))
		{
			_v_hidden = "msHidden";
			_v_change = "msvisibilitychange";
		}else
		if (untyped __js__('typeof document.webkitHidden !== "undefined"'))
		{
			_v_hidden = "webkitHidden";
			_v_change = "webkitvisibilitychange";
		}else {
			_v_hidden = ""; // No Compatibility
		}
		
		Browser.document.addEventListener(_v_change, onVisibilityChange, true);
		onVisibilityChange();
		
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Listeners 
	//====================================================;
	
	// --
	function onFocus()
	{
		isFocused = true;
	}//---------------------------------------------------;
	
	// --
	function onBlur()
	{
		isFocused = false;
	}//---------------------------------------------------;
	
	
	/**
	* Override and add custom functionality
	*/
	function onResize()
	{
		// el.offsetHeight changed
		// el.offsetWidth changed
		
		width = Browser.window.innerWidth;
		height = Browser.window.innerHeight;

		currentPage.onResize();
		
		// -- Do an extra onscroll check
		onScroll();
	}//---------------------------------------------------;
	

	/**
	 * Root onScroll, called on every element scroll event
	 * This is an intermediate to the true onScroll, creates
	 * a time buffer to offer a smooth and more lightweight solution
	 */
	function __onScroll()
	{
		if (_scrollCheckLock == false)
		{
			_scrollCheckLock = true;
			Timer.delay(function() {
				 // trace("- Unlocking scrollcheck and Waiting...");
				_scrollCheckLock = false;
				onScroll();
			},params.scrollCheckFreq);
		}
		
	}//---------------------------------------------------;
	
	
	/**
	 * # OVERRIDE THIS TO ADD FUNCTIONALITY
	 * Time-Buffered onScroll().
	 */
	function onScroll()
	{	
		scroll_prev = scroll_top;
		scroll_top = Browser.window.scrollY;
		scroll_bottom = scroll_top + Browser.window.innerHeight;
		
		// -- Header
		if (header != null)
		{
			header.update();
		}
		
		// trace('NewScroll :: scroll_top:$scroll_top | scroll_bottom:$scroll_bottom');
		
		currentPage.onScroll();
	}//---------------------------------------------------;
	
	
	/**
	 * # MOBILE ONLY
	 * Oriantation is changed
	 * Check "isPortrait"
	 */
	function onOrientationChange()
	{
		isPortrait = !(Math.abs(untyped(Browser.window.screen.orientation.angle)) == 90);
		trace("+ Orientation Change, Portrait = ", isPortrait);
		currentPage.onOrientationChange();
	}//---------------------------------------------------;
	
	
	/**
	 * Browser Page went on or off screen
	 * Extended Object, check "isVisible"
	 */
	function onVisibilityChange()
	{
		isVisible = !Reflect.getProperty(Browser.document, _v_hidden);
		currentPage.onVisibilityChange();
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Internal
	//====================================================;
	
	/**
	 * Create a Background/Container
	 * This is the main page container element where everything is added to
	 * @param	scrollable_
	 */
	function createContainer()
	{
		el = W.dom.newElement("div");
		bg = el; // Use the main element as the BG
		
		if (params.scrollable) {
			
			if (params.staticBG)
			{
				el.style.position = "absolute";
				// -
				bg = W.dom.newElement('div');
				bg.style.width = "100%";
				bg.style.height = "100%";
				bg.style.display = "block";
				bg.style.position = "fixed";
				bg.style.zIndex = "0";
				Browser.document.body.appendChild(bg);
				
			}else
			{
				el.style.minHeight = "100vh";
			}
			
		}else
		{
			// The window will never present any scrollbars ever
			Browser.document.body.style.overflow = "hidden";
			el.style.height = "100vh";
			el.style.overflow = "hidden";
		}
		
		W.dom.qStyle(el, { 	
			width:"100%", display:"block", margin:"0", padding:"0", zIndex:"1", overflowX:"hidden"
		});
		
		Browser.document.body.appendChild(el);
	}//---------------------------------------------------;
	
	//====================================================;
	// Dynamic Header
	//====================================================;
	
	/**
	 * Set an element to be a fixed header
	 * Style will be altered.
	 * The header will recieve scroll callbacks to change size
	 * @param el Must be of Interface IHeader
	 */
	public function addHeader(h_:FixedHeader)
	{
		#if debug
			if (header != null) throw "Header already exists";
		#end
		
		header = h_;
		
		//-- Add a ghost element just to reserve the space behind the header
		if (h_.ghostEl != null) 
		{
			el.insertBefore(h_.ghostEl, currentPage.el);
		}
		
		el.insertBefore(h_.el, currentPage.el);
	}//---------------------------------------------------;
	
	
	
	//====================================================;
	// PAGES
	// -----
	//====================================================;
	
	/**
	 * Add a page to the page list
	 * @param	p_
	 * @param	sid
	 */
	public function addPage(p_:Page, ?setNow:Dynamic)
	{
		pages.set(p_.sid, p_);
		// This is javascript, I can check nulls
		if (setNow == true) setPage(p_.sid);
	}//---------------------------------------------------;
	
	/**
	 * Replaces current page with new page
	 * @param	id
	 * @param	data  Optional page parameters
	 */
	public function setPage(sid:String, ?data:Dynamic)
	{
		el.removeChild(currentPage.el); currentPage.isOn = false;
		currentPage = pages.get(sid);
		el.appendChild(currentPage.el); currentPage.isOn = true;
		currentPage.init(data);
		
		currentPage.onResize();
		currentPage.onScroll();
	}//---------------------------------------------------;
	
	
	//====================================================;
	// MODALS
	// ------
	// Simple and basic modal functionality
	//====================================================;
	
	// Keep track of any open modals
	var modals:Array<Element> = null;
	var callback_modalOnClose:Void->Void = null;
	
	/**
	 * Create and add a fullscreen modal to the page
	 * 
	 * @return The modal itself add elements to it or whatever
	 */
	public function createModal(?callback:Void->Void):Element
	{
		closeModal(); // If any
		
		var n = W.dom.newElement("div");
			W.dom.qStyle(n, { position:"fixed", width:"100%", height:"100%",
				left:"0", top:"0", overflow:"none", display:"block",
				background:"#020202", opacity:"0.95" 
			});
			
		var m = W.dom.newElement("div");
			W.dom.qStyle(m, { position:"fixed", width:"100%", height:"100%",
				left:"0", top:"0", overflow:"none", display:"block"
			});
			
		W.dom.toFlex(m, "column", "start");
		
		// --
		modals = [n, m];
		callback_modalOnClose = callback;
	
		Browser.window.onkeydown = function(e:KeyboardEvent) {
			if (e.keyCode == 27) // ESCAPE KEY 
				closeModal();
		}//----
		
		m.onmouseup = function(e:MouseEvent) {
			if (e.button == 0) // LEFT CLICK
				closeModal();
		}//-----
		
		// -- Container with close button --
		var topStrip = W.text.fText("Click anywhere or press [ESC] to close.", { size:8, color:"#BBB", padding:"6px", display:"inline", bgColor:"black" } );
			topStrip.style.cursor = "pointer";
			topStrip.style.alignSelf = "center";
			
		var container = W.dom.newElement('div');
			container.style.flex = "1";
					
		m.appendChild(container);
		m.appendChild(topStrip);
		
		el.appendChild(n);
		el.appendChild(m);
		
		return container;
	
	}//---------------------------------------------------;
	
	/**
	 * Close the modal
	 */
	public function closeModal()
	{
		if (modals == null) return;
		
		// TODO: A global key handler
		Browser.window.onkeydown = null;
		
		el.removeChild(modals[0]);
		el.removeChild(modals[1]);
		if (callback_modalOnClose != null) callback_modalOnClose();
		callback_modalOnClose = null;
		modals = null;
		
	}//---------------------------------------------------;
	
	
}// --






	/**
	 * -- Copy Paste this function, put on child --
	static function main() {
		js.Browser.document.body.onload = function() {
			new MyWebPage();
		}
	}//---------------------------------------------------;*/