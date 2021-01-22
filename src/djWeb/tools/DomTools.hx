package djWeb.tools;

import djWeb.tools.TextTools.TextStyle;
import js.Browser;
import js.html.Element;
import js.html.Image;
import js.html.LinkElement;
import js.html.MetaElement;

/**
 * DOM related
 * General Purpose Helper Functions
 * ...
 * Accessed by W.dom
 * 
 * notes:
 * flex help: https://css-tricks.com/snippets/css/a-guide-to-flexbox/
 */
class DomTools
{
	#if debug
	// If true, then some borders will be applied to created elements for design purposes
	public var useBorderGuides:Bool = false;
	#end
	//====================================================;
	

	public function new() { }
	
	/**
	 * Quick way to create a new DOM element
	 * @param	tag 
	 */
	public inline function newElement(tag:String):Element
	{ 
		return Browser.document.createElement(tag);
	}//---------------------------------------------------;

	
	/**
	 * Returns a new <a href=url> element including the passed ELement
	 * @param	el The element to be included in the <a>
	 * @param	url Url to go to
	 * @param	newTab Bool, Default = True
	 * @return DOM <a> Element
	 */
	public function toLink(el:Element, url:String, newTab:Bool = false):Element
	{
		var l = newLink(url, newTab, null); l.appendChild(el); return l;
	}//---------------------------------------------------;
	
	/**
	 * Return a new <a href=url> element
	 * @param	url --
	 * @param	newTab Bool, Default = True
	 * @param	cssStyle Optional class name must be in the CSS
	 * @return
	 */
	public function newLink(url:String, newTab:Bool = false, ?cssStyle:String):Element
	{
		var a:LinkElement = cast newElement("a");
		if (newTab) a.target = "_blank";
		if (cssStyle != null) a.className = cssStyle;
		a.href = url;
		return a;
	}//---------------------------------------------------;
	
	
	/**
	 * Returns a new <a href=url> element including an image object
	 * @param	source the source URL for the image
	 * @param	url Url to go to
	 * @param	newTab Bool, Default = True
	 * @return DOM <a> Element
	 */
	public function newLinkImage(source:String, url:String, newTab:Bool = true):Element
	{
		var im:Image = new Image();
			im.src = source;
		return toLink(im, url, newTab);
	}//---------------------------------------------------;
	
	
	// HELPER
	// Append multiple to a single element
	public inline function qAppend(el:Element, list:Array<Element>)
	{
		for (i in list) { el.appendChild(i); }
	}//---------------------------------------------------;
	
	
	// HELPER
	// Quick Style,Copy the styles to the object styles
	public function qStyle(el:Element, styles:Dynamic)
	{
		for (i in Reflect.fields(styles)) {
			Reflect.setField(el.style, i, Reflect.field(styles, i));
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Get a plain DIV box
	 * @param	width INT (pixels) or STRING (css)
	 * @param	height INT (pixels) or STRING (css)
	 * @return
	 */
	public function getBox(width:Dynamic, height:Dynamic):Element
	{
		var el = newElement("div");
		
			el.style.display = "block";
			
			if(Std.is(width,Int))
				el.style.width = '${width}px'
			else if (Std.is(width, String))
				el.style.width = width;
				
			if(Std.is(height,Int))
				el.style.height = '${height}px'
			else if (Std.is(height, String))
				el.style.height = height;			
				
		return el;
	}//---------------------------------------------------;
	
	/**
	 * Set an element to a flex box
	 * @param	el The element to have FLEX aplied to
	 * @param	dir Puts elements in a [row, column]
	 * @param	justify [(start), end, center], Space between items to fit the main axis
	 * @param   align [(flex-start),flex-end,center,stretch] , Item alignment along the cross axis
	 */
	public function toFlex(el:Element, dir:String = "row", ?justify:String, ?align:String )
	{
		el.style.display = "flex";
		el.style.flexDirection = dir;
		el.style.flexWrap = "wrap";
		el.style.justifyContent = (justify == "center"?"":"flex-") + justify;
		el.style.alignItems = align;
		// el.style.alignContent // Align the group in relation to the container
	}//---------------------------------------------------;
	
	/**
	 * Quickly create a DIV and set it to flex
	 * @param	dir Puts elements at a [row, column]
	 * @param	justify [(start), end, center], Space between items to fit the main axis
	 * @param	align [(flex-start),flex-end,center,stretch] , Item alignment along the cross axis
	 * @return
	 */
	public function newFlex(dir:String = "row", ?justify:String, ?align:String):Element
	{
		var box = newElement("div");
		toFlex(box, dir, justify, align);
		return box;
	}//---------------------------------------------------;
	
	/**
	 * Gets a new box to be put inside a flex box
	 * @param	flexW The CSS 'flex' value.
	 * @param	align [flex-start, flex-end, center, stretch, baseline, auto]
	 * @param	innerHTML Optional content for the item
	 * @return
	 */
	public function getFlexItem(flexW:Int, align:String = "auto", ?innerHTML:String):Element
	{
		var flex = newElement("div");
			flex.style.flex = Std.string(flexW);
			flex.style.alignSelf = align;
			flex.innerHTML = innerHTML != null?innerHTML:"";
		#if debug
			if(useBorderGuides) flex.style.border = "1px solid #666";
		#end
		return flex;
	}//---------------------------------------------------;
		
	
	
	//====================================================;
	// LISTS
	//====================================================;
	
	/**
	 * Returns a LI element, with a custom bullet if an image is set.
	 * Be sure the image is SQUARE in dimensions
	 * @param	text The Text
	 * @param	imageURL The image 
	 * @param	topMargin Top Margin for each bullet
	 * @param	textPad How far to the right,0 will overlap the image
	 * @return
	 */
	public function getLI(text:String, imageURL:String, topMargin:Int = 4, textPad:Int = 32):Element
	{
		var li = newElement('li');
		li.style.background = 'url(\'${imageURL}\') no-repeat left 2px';
		li.style.paddingLeft = '${textPad}px';
		li.style.marginTop = '${topMargin}px';
		li.style.listStyle = "none";
		li.style.fontFamily = "inherit";
		li.innerHTML = text;
		return li;
	}//---------------------------------------------------;
	
	
	
	//====================================================;
	// CSS and styles
	//====================================================;
	
	/**
	 * Adds a css string to the document, applies immediately
	 * @param	stylename
	 * @param	cssText
	 */
	public function CSS_AddStyle(stylename:String, cssText:String)
	{
		// Removing a style:
		// var styleElement = Helper.getElementOrID(stylename);
		// if (styleElement != null) {
		// Browser.document.getElementsByTagName('head')[0].removeChild(styleElement);
		//
		
		var styleElement = newElement('style');
		//styleElement.itemType = 'text/css';
		styleElement.id = stylename;
		styleElement.innerHTML = cssText;
		Browser.document.getElementsByTagName('head')[0].appendChild(styleElement);
	}//---------------------------------------------------;
	
	
	/**
	 * Add a meta tag to the document
	 * useful: [ description, theme-color ]
	 * @param	name
	 * @param	content
	 */
	public function ADD_META(name:String, content:String)
	{
		var meta:MetaElement = cast newElement('meta');
		meta.name = name;
		meta.content = content;
		Browser.document.getElementsByTagName('head')[0].appendChild(meta);
	}//---------------------------------------------------;
	
}// --