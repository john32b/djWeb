package djWeb;
import djWeb.tools.Helper;
import js.html.Element;

/**
 * This is a property, any element can have a ScrollAware property
 * Just call page.trackScroll(..) to begin tracking
 * ...
 */
class ScrollAware 
{
	// -- Pointer to the element affected
	public var el(default, null):Element;
	
	// -- Is Currently in view
	public var isVisible(default, null):Bool;

	// -- Called when this just gets on view
	public var callback_ON:Void->Void;
	
	// -- Called when this just gets off view
	public var callback_OFF:Void->Void;
	
	// -- Extra padding to calculate when at the edges of the screen
	public var trigger_offset:Int = 10;
	
	// FLAGS 
	//====================================================;
	
	// -- If true it will fade when on/off
	public var flag_fade(default, null):Bool;
	
	// -- If true it will remove itself from the manager after setting on
	public var flag_fire_once(default, null):Bool;
	
	
	// FUNCTIONS
	//====================================================;

	/**
	 * @param _el Pointer to the element affected
	 * @param _fire_once Pointer to the element affected
	 * @param _fade Use a fade effect
	 */
	public function new(_el:Element, _fire_once:Bool = false , _fade:Bool = false)
	{
		el = _el;
		isVisible = false;
		flag_fade = _fade;
		flag_fire_once = _fire_once;
		if (flag_fade) {
			Helper.appendTransition(el, "opacity 0.25s ease-out");
			el.style.opacity = "0";
		}
		
	}//---------------------------------------------------;
	
	
	/**
	 * Force a scroll check of the object
	 */
	public function checkScroll()
	{
		var sc1 = el.offsetTop + trigger_offset;
		var sc2 = sc1 + el.offsetHeight - (trigger_offset * 2);
	
		if (sc1 <= W.main.scroll_bottom && sc2 >= W.main.scroll_top) 
		{
			if (!isVisible) setON();
		}else
		{
			if (isVisible) setOFF();
		}

	}//---------------------------------------------------;
	
	/**
	 * Automatically called when scrolled IN view
	 */
	function setON()
	{
		isVisible = true;
		
		if (flag_fade) 
		{
			el.style.opacity = "1";
		}
		
		if (flag_fire_once)
		{
			W.main.currentPage._scTrDelList.push(this);
		}
		
		if (callback_ON != null) callback_ON();
	}//---------------------------------------------------;
	
	/**
	 * Automatically called when scrolled OUT of view
	 */
	function setOFF()
	{
		isVisible = false;
		
		// -- No reason to fade out? Browser can handle off-screen elements
		if (flag_fade) {
			el.style.opacity = "0";
		}
		
		if (callback_OFF != null) callback_OFF();
	}//---------------------------------------------------;
	
}// --