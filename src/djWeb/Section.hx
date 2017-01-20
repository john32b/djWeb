package djWeb;

import djWeb.tools.Helper;
import js.html.Element;

/**
 * General Purpose Section
 * -----
 * Help:
 *  .createBGStrip();
 *  .setResizeBehavior()
 * 
 * 
 * resizeType :  [fixed|rubber|steps]
 *  fixed, static width
 *  rubber, autoresize
 *  step, min,max 2 steps only
 */
class Section
{
	
	// The default style for ALL created sections
	// You can tweal this style here, or pass a new style
	// at the constructor of sections.
	public static var defStyle:Dynamic = {
		width:"800px", 
		height:"auto", 
		minHeight:null,
		marginBottom:"0",
		marginTop:"0",
		padding:"4px",
		backgroundColor:null
	};
	
	inline static var RESIZE_RUBBER:Int = 1;
	inline static var RESIZE_STEPS:Int = 2;
	inline static var RESIZE_FIXED:Int = 3;
	
	//====================================================;
	
	// -- Mostly debug use
	public var name(default, null):String;
	
	// -- Pointer to the page this belongs to.
	public var page:Page;
	
	// -- The main container
	public var el(default, null):Element;
	
	// -- Optional
	public var bg(default, null):Element = null;
	
	// -- Resize parameters ::
	public var resizeType(default, null):Int = RESIZE_FIXED;
	
	// -- Used only when RESIZE_STEPS
	// .{ min:int, max:int, current:0:small, 1:big, -1:uninitialized
	var _stepsD:Dynamic = null;
	
	/** # TEST **/
	// - Pointer to the next section, I might need it?
	// public var next:Section;
	
	// -- ScrollAware
	// If you create it before adding to the page, it's going to get added immediately
	public var scrollAware:ScrollAware = null;
	
	//---------------------------------------------------;

	/**
	 * Create a section, it's a plain DIV box that goes inside a Page
	 * @param	style CSS Style to be applied
	 */
	public function new(?style:Dynamic) 
	{
		el = W.dom.newElement('div');
		
		// - Center the section to the center
		el.style.marginLeft = "auto";
		el.style.marginRight = "auto";
		
		style = Helper.defParams(style, defStyle);
		
		W.dom.qStyle(el, style);
		
		// scrollAware = new ScrollAware(el, true, true); /// debug <--- delete
		// NOTE: You should enable scrolltrack on the constructor

	}//---------------------------------------------------;
	
	/**
	 * # Note : It's optional and not called anywhere but from user
	 * Dynamically change the elements to reflect new data,
	 * Useful if you want to reuse sections
	 * @param	data
	 */
	public function init(data:Dynamic)
	{
		// -- OVERRIDE 
	}//---------------------------------------------------;

	/**
	 * This section was just added to a page,
	 * provided for extra initialization that requires a page to be set
	 */
	public function onAddedToPage()
	{
		// -- OVERRIDE
	}//---------------------------------------------------;
	
	/**
	 * Create a strip background that expands horizontally to the window behind the section
	 * Call this before adding the section to the page
	 * e.g. createBGString("black");
	 */
	public function createBGStrip(?bgCSS:String)
	{
		bg = W.dom.newElement('div');
		bg.style.width = "100%";
		bg.style.height = el.style.height;
		bg.style.background = bgCSS;
		bg.appendChild(el); // don't forget. PAGE will add (bg) instead of (el)
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Resize Handler
	//====================================================;

	
	/**
	 * Set a custom resizing behavior
	 * @param	type  [fixed|rubber|steps]
	 * @param	params Array [min,max]
	 * 	
	 */
	 public function setResizeBehavior(type:String, steps:Array<Int>)
	{
		if (type == "rubber")
		{
			el.style.width = "";
			el.style.minWidth = steps[0] + "px";
			el.style.maxWidth = steps[1] + "px";
			resizeType = RESIZE_RUBBER;
		}else
		if (type == "steps")
		{
			_stepsD = {
				min:steps[0],
				max:steps[1],
				current:-1
			};
			resizeType = RESIZE_STEPS;
			
			// - Optional css transition
			// WARNING !! A width transition may bug out some elements on the first page appearance, 
			// 			  as they wouldn't be in their final position when checking for scroll events
			//			  You can set a manual scroll check after 0.2 seconds to account for that
			// Helper.appendTransition(el, 'width 0.2s ease-out');
			
			// Avoid jerky transition by setting it to a value
			el.style.width = steps[0] + 'px';

		}else
		{
			// This is the default
			// also you should not call this function more than once!
			// TODO: undo the min/maxwidth and set a static width??
			resizeType = RESIZE_FIXED;
		}
	}//---------------------------------------------------;

	/**
	 * Autocalled when Page it belongs to has been resized
	 */
	@:allow(djWeb.Page)
	private	function handleResize()
	{
		// Only needs to process when resize_steps is set
		if (resizeType != RESIZE_STEPS) return;
		
		// -- Currently only works for min and max
		// Future : make it for multiple steps.
		if (_stepsD.current != 0 && page.width < _stepsD.max)
		{
			el.style.width = '${_stepsD.min}px';
			_stepsD.current = 0;
			onStepResize(0);
		}else
		if (_stepsD.current != 1 && page.width >= _stepsD.max)
		{
			el.style.width = '${_stepsD.max}px';
			_stepsD.current = 1;
			onStepResize(1);
		}
		
		/// TODO: user callback on new size snap?
	}//---------------------------------------------------;
	
	
	//====================================================;
	// EVENTS
	//====================================================;
	
	
	/**
	 * AutoCalled when it's resized to a step
	 * @param	step 0:small, 1:wide
	 */
	public function onStepResize(step:Int)
	{
		// -- Override and customize
	}//---------------------------------------------------;
	
	
}// -- end class --