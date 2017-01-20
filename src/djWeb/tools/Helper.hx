package djWeb.tools;

import js.Browser;
import js.html.Element;
import js.html.HTMLCollection;
import js.html.Node;
import js.html.NodeList;

/*
 * Various Javascript + Web helper functions
 */

@:expose("Helper")
class Helper 
{
	/**
	 * Figure out that the input is, either an element or ID of an element.
	 * and return the element
	 * @param el Element ID or Element
	 */
	public static function getElementOrID(el:Dynamic):Element
	{
		if (Std.is(el, String))
		{
			return Browser.document.getElementById(el);
		}
		else if(Std.is(el,Element))
		{
			return el;
		}
		else
		{
			return null;
		}
	}//---------------------------------------------------;	
	
	/**
	 * Gets a collection of elements from a dynamic source and applies a 
	 * function to each element of that collection.
	 * @param	source one of [],id,element
	 * @param	funct function to run for each element
	 * @return  Array of all elements got.
	 */
	public static function getElementsMultiAndDo(source:Dynamic, ?funct:Element->Void):Array<Element>
	{
		var el:Array<Element> = null;

		// Nodelist is for elements got using the document.querySelectorAll() method
		// .
		if (Std.is(source, Array) || Std.is(source,NodeList) || Std.is(source,HTMLCollection))
		{
			el = [];
			var arr:Array<Dynamic> = untyped(source);
			for (i in arr) {
				el.push(getElementOrID(i));
			}
		}
		else 
		{
			// Just one element in array[0] position
			el = [ getElementOrID(source) ];
		}
	
		// Apply a function
		if (funct != null) {
			for (i in el) funct(i);
		}
		
		return el;
	}//---------------------------------------------------;
	
	
	//- Create a fullPage DIV element
	//  and add all the body children into it.
	
	//  WARNING: This will remove and re-add all the elements
	// 			 and it will break animations etc. Use with caution
	public static function createFullPageBG(scrollableHeight:Bool = false):Element
	{
		var bg = Browser.document.createElement("div");
		
		if (scrollableHeight)
		{
			bg.style.height = "100%";
			bg.style.overflowX  = "hidden";
		}
		else
		{
			bg.style.height = "100vh";
			bg.style.overflow = "hidden";
		}
		
		bg.style.width  	= "100vw";
		bg.style.display 	= "block";
		bg.style.position 	= "absolute"; //or fixed?
		bg.style.margin 	= "0";
		bg.style.zIndex 	= "0";
		
		//--Transfer all the elements from the body to the bg
		
		// Do not add if a tag is one of these
		var skipTags = ["SCRIPT","STYLE","META"];
		var i=0;
		var elems:Array<Element>=[];
		
		// Get all elements from the body
		while (i < Browser.document.body.childElementCount) {
			var c:Element = untyped(Browser.document.body.children[i++]);
			if (skipTags.indexOf(c.tagName) < 0)
				elems.push(c);
		}
		// Add the elements to the bg, note this also removes them from the body
		while (elems.length > 0) {
			bg.appendChild(elems.shift());
		}
		
		Browser.document.body.appendChild(bg);
		return bg;
	}//--------------------------------------------------;
	
	
	
	/**
	 * Quick way to set a background of an element
	 * @param	type [color, animtile, tile, image]
	 * @param	par color or file
	 */
	public static function setBackground(el:Element, type:String, par:String)
	{
		switch(type)
		{
			case "animtile":
				// djWeb.BgTileScroller.quickSetBG(el, par);
			case "tile":
				el.style.backgroundImage = 'url(${par})';
				el.style.backgroundRepeat = 'repeat';
			case "image":
				el.style.backgroundImage = 'url(${par})';
				el.style.backgroundRepeat = 'no-repeat';
			case "color":
				el.style.backgroundColor = par;
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Quickly make overlapping elements
	 * 
	 * @param	el The element to alter
	 * @param	front Put it on front, or back (false)
	 */
	public static function setOverlapping(el:Element, front:Bool = true)
	{
		if (front) {
			el.style.position = "relative"; // front
		}else {
			el.style.position = "absolute";	// back
		}
		// el.style.left = "0px";
		// el.style.top = "0px";
	}//---------------------------------------------------;



	//====================================================;
	// DATA
	//====================================================;
	
	//-- Quickly set the default parameters of an object
	public static function defParams(obj:Dynamic, template:Dynamic):Dynamic
	{
		if (obj == null) {
			return Reflect.copy(template); // NEW <--
		} else {
			// THIS IS VERY IMPORTANT ::
			obj = Reflect.copy(obj);
		}
		
		for (field in Reflect.fields(template)) {
			if (!Reflect.hasField(obj, field)) {
				Reflect.setField(obj, field, Reflect.field(template, field));
			}
		}
		
		return obj;
	}//---------------------------------------------------;
	
	
	
	/**
	 * Clear any selections that may have been selected by mistake or whatnot
	 */
	public static function clearAllSelections() 
	{
		if (Browser.window.getSelection != null)
			Browser.window.getSelection().removeAllRanges();
	}//---------------------------------------------------;
	
	
	
	/**
	 * Append a transition style to an element
	 */
	public static function appendTransition(el:Element, trans:String)
	{
		if (el.style.transition.length == 0){
			el.style.transition = trans;
		}
		else{
			el.style.transition += ',$trans';
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Remove a transition property from a style
	 */
	public static function removeTransition(el:Element, property:String)
	{
		var ll:Array<String> = el.style.transition.split(', '); // yes, comma with a leading space
		var c = 0;
		do {
			if (ll[c].indexOf(property) >-1) // or ==0 because it must start with it
			{
				ll.splice(c, 1);
				el.style.transition = ll.join(',');
				break;
			}
		}while (++c < ll.length);
		
		/// TODO, do this with REGEX ??
	}//---------------------------------------------------;
		
	
	//====================================================;
	// Generalize some tasks
	//====================================================;

	
	// Return the size of an element that is't on the DOM
	// This is a hack, and will actually put the element on the DOM,
	// return the offsetsize, and then remove it again :-/
	
	// NOTE:
	// -----
	// This is a retarded and slow way, because the DOM is redrawn everytime
	// something is being added to it.
	// Do not use for many elements. or in loops.
	@:deprecated("This function is just wrong")
	public static function getSizeBeforeDom(el:Element):Array<Int>
	{
		var parent = el.parentElement;
		
		var wasInvisible:Bool = (el.style.visibility == "hidden");
		
		if (!wasInvisible)
			el.style.visibility = "hidden";
		
		Browser.document.body.appendChild(el);
		
		var ar = [el.clientWidth, el.clientHeight];
		
		if (parent != null)
			parent.appendChild(el);
		else
			Browser.document.body.removeChild(el);
		
		if (!wasInvisible)
			el.style.visibility = "visible";
		
		return ar;
	}//---------------------------------------------------;
	
	public static function insertHREF(string:String, url:String, ?classname:String = "link"):String
	{
		return ~/%(.+)%/.replace(string, '<a href="$url" target="_blank" class="$classname">$1</a>');
	}//---------------------------------------------------;
}//-- end --//