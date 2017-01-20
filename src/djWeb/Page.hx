package djWeb;
import js.html.Element;

/**
 * A page is a collection of Sections
 * ...
 * Currently only one page visible at each time
 */
@:allow(djWeb.MainFrame)
class Page
{

	/**
	 * The MAIN container where everything is added to.
	 */
	public var el(default, null):Element;
	
	// - Hold all the sections in this mail
	public var sections:Array<Section> = [];
	
	// - Hold the pages, SID
	public var sid(default, null):String;
	
	// The width of the page in pixels
	public var width(get, null):Int;
	
	// Is this page currently added and visible on the mainframe? 
	public var isOn:Bool = false; // #SETBY mainframe
	
	// Keep track of all scroll aware elements and automatically process them on scroll
	var scrollTracked:Array<ScrollAware>;
	
	// A list of elements to remove from the scrollTracked list
	@:allow(djWeb.ScrollAware)
	var _scTrDelList:Array<ScrollAware>;
	
	//
	//---------------------------------------------------;
	/**
	 * 
	 * @param	sid_ Every page must have a unique ID
	 */
	public function new(sid_:String) 
	{
		sid = sid_;
		el = W.dom.newElement('div');
		scrollTracked = [];
		_scTrDelList = [];
	}//---------------------------------------------------;

	/**
	 * Optional initialize a page with custom data
	 * Useful in dynamic pages, e.g. A movie description page, where the infos change
	 * @param	data User Data
	 */
	public function init(data:Dynamic)
	{
		// -- Optional get and process data
		// -- Page just added to the DOM, do extra initialization
		
		// -- Scroll Elements Check :: 
	}//---------------------------------------------------;

	/**
	 * Add a section to the page
	 * @param	s
	 */
	public function add(s:Section)
	{
		sections.push(s);
		s.page = this;
		if (s.bg != null) el.appendChild(s.bg); else el.appendChild(s.el);
		s.onAddedToPage();
		if (isOn) s.handleResize(); // Avoid errors, make sure the page is up
		if (s.scrollAware != null) trackScroll(s.scrollAware);
	}//---------------------------------------------------;
	
	
	//====================================================;
	// SCROLL TRACK 
	//====================================================;
	
	/**
	 * Begin tracking an scroll-aware object
	 * @param	obj
	 */
	public function trackScroll(obj:ScrollAware)
	{
		if (obj == null) return;
		
		scrollTracked.push(obj);
		
		if (isOn)
		{
			obj.checkScroll();
		}
	}//---------------------------------------------------;
	
	//====================================================;
	// EVENT HANDLERS
	//====================================================;
	
	function onResize()
	{
		// -- Check 'W.main.{width.height}'
		for (s in sections)
		{
			s.handleResize();
		}
	}//---------------------------------------------------;
	
	
	function onScroll()
	{
		// -- NotE:: Fires at a time buffered rate 
		// -- FUTURE, if I want direct OnScroll events, implement it.
		
		 for (st in scrollTracked)
		 {
			 st.checkScroll();
		 }
		 
		 if (_scTrDelList.length > 0)
		 {
			 for (sd in _scTrDelList) {
				 scrollTracked.remove(sd);
			 }
			 
			 _scTrDelList = [];
		 }
	}//---------------------------------------------------;
	
	function onOrientationChange()
	{
		// -- Check 'W.main.isPortrait'
	}//---------------------------------------------------;
	
	function onVisibilityChange()
	{
		// -- Check 'W.main.isVisible'
	}//---------------------------------------------------;
	
	
	
	//====================================================;
	// GETTERS, SETTERS 
	//====================================================;
	
	function get_width():Int
	{
		return el.offsetWidth;
	}//---------------------------------------------------;
	
}// -- end --