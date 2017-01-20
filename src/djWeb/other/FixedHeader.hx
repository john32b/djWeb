package djWeb.other;

import djWeb.tools.Helper;
import js.html.Element;

/**
 * A Top header element that is FIXED to the screen
 * ...
 * #OVERRIDE this to create a custom header 
 * 
 * #USE : Add a fixed header with Main.addHeader(..) Do it before adding anything else
 */
class FixedHeader
{
	
	static var defParams(default, never):Dynamic = {
		maxHeight:64,
		minHeight:32,
		height:32, 			// Used only when autohide. Sets the height to this one
		scrollTrigger:0, 	// if 0 it will be autocalculated. if >0 it will be custom
		autoHide:false
		// TODO + 2states like mobile behavior
	};
	
	// An empty element that does not float and simulates the fullheight of the header
	// Added be mainframe
	public var ghostEl:Element;
	// The main element
	public var el:Element;
	// Need to scroll this much down to trigger the size change
	public var scrollTrigger:Int;
	// Is the element currently tall or short
	public var isTall:Bool;
	// The height of the element when it is TALL
	public var maxHeight(default, null):Int;
	// The height of the element when
	public var minHeight(default, null):Int;
	// Applicable when flag_autoHide is enabled
	public var isVisible(default, null):Bool;
	
	// --
	// Will only show the short state when scrollAmount triggers
	public var flag_autoHide(default, null):Bool;
	
	// Keep the last top scroll to calculate deltas
	// var _lastScroll:Int;
	
	//====================================================;
	
	/**
	 * 
	 * @param	maxHeight Check defParams for full list
	 */
	public function new(params:Dynamic)
	{
		params = Helper.defParams(params, defParams);
		
		maxHeight = params.maxHeight;
		minHeight = params.minHeight;
				
		scrollTrigger = params.scrollTrigger;
		flag_autoHide = params.autoHide;
		
		if (flag_autoHide)
		{
			isVisible = true;
			minHeight = params.height;
			maxHeight = params.height;
		}else
		{
			// -- create the ghost element if not AutoHide
			ghostEl = W.dom.getBox(null, maxHeight);
		}
		
		// - Autocalculate the scroll trigger
		if (scrollTrigger == 0)
		{
			scrollTrigger = Std.int(maxHeight * 0.8);
		}
		
		el = W.dom.newElement('div');
		
		W.dom.qStyle(el, { 
			position:'fixed', top:'0px', width:'100%',
			transition:'all 0.2s ease-in-out', margin:0,
			height:'${maxHeight}px', display:'block',zIndex:999
		});
		
		// Starting position as tall only
		// Be sure extended class starts as TALL
		isTall = true;
		
		update();
	}//---------------------------------------------------;
	
	
	/**
	 * AutoCalled - When scrolling occurs
	 */
	public function update()
	{
		// calculate delta
		
		if (flag_autoHide)
		{
			// ------- Short , Hide behavior
			if (W.main.scroll_top > scrollTrigger)
			{
				setVisible(true);
			}else
			{
				setVisible(false);
			}
		}else 
		{
			// ------- Tall, Short Behavior
			if (isTall && W.main.scroll_top > scrollTrigger)
			{
				setSize(0); // set short
			}else
			{
				if (!isTall && W.main.scroll_top <= scrollTrigger)
				{
					setSize(1);
				}
			}
		}
	}//---------------------------------------------------;
	
	/**
	 * Autocalled when scrolling, Handle the size and elements positions etc.
	 * #  Force Set #
	 * @param	size 0:Small | 1:Big
	 */
	dynamic public function setSize(size:Int):Void
	{
		isTall = (size == 1);
		
		if (isTall)
		{
			el.style.height = maxHeight + 'px';
		}else
		{
			el.style.height = minHeight + 'px';
		}
	}//---------------------------------------------------;
	
	/**
	 * 
	 * @param show false to hide
	 */
	function setVisible(value:Bool)
	{
		if (isVisible == value) return;
			isVisible = value;
			
		if (isVisible) {
			//el.style.visibility = 'visible';
			el.style.top = "0px";
		}else {
			//el.style.visibility = 'hidden';
			el.style.top = '-${maxHeight}px';
		}
	}//---------------------------------------------------;
	
}// -- 