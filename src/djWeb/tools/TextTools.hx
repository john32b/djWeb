package djWeb.tools;

import js.html.Element;

/**
 * Quick Text element generators and stylings
 * ...
 */
class TextTools
{
	// -- Keep all the styles.
	var textStyles:Map<String,TextStyle>;
	
	//====================================================;
	
	/**
	 * 
	 */
	public function new() 
	{
		// Create a basic default text style
		textStyles = new Map();
		textStyles.set("default", {
				color : "#fff",
				size : 24,	
				bold : "0"
			});
	}//---------------------------------------------------;
	
	/**
	 * Apply a text style to an element.
	 * @param	el The element to apply the style to
	 * @param	s The style ID, it must exist, defined with addStyle(...)
	 */
	public function applyStyle(el:Element, s:TextStyle)
	{
		if (s.font != null) el.style.fontFamily = s.font;
		el.style.fontSize = '${s.size}px';
		el.style.backgroundColor = s.bgColor;
		el.style.fontWeight = s.bold;
		el.style.textShadow = s.shadow;
		el.style.color = s.color; // -- samename >>>
		el.style.padding = s.padding;
		el.style.display = s.display;
		el.style.textAlign = s.align;
		//TODO: margin?
	}//---------------------------------------------------;
	
	/**
	 * 
	 * @param	id Give a unique ID for the style
	 * @param	s color,size(int),{font,bgColor,shadow,bold,display,padding} optional
	 */
	public function addStyle(id:String, s:TextStyle)
	{
		#if debug
		if (textStyles.exists(id)) throw 'Textstyle with [$id] already exists';
		#end
		textStyles.set(id, s);
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Text Generation 
	//====================================================;
	
	/**
	 * Get a styled Text Node from a predefined TextStyle
	 * TextStyles are handled by the "Styles.hx" Class
	 */
	public function sText(text:String, styleID:String):Element
	{
		var e = W.dom.newElement("p");
			e.innerHTML = text;
		var s = textStyles.get(styleID);
		#if debug
			if (s == null) throw 'TextStyle ($styleID) does not exist';
		#end
		applyStyle(e, s);
		return e;
	}//---------------------------------------------------;
	
	/**
	 * Get a styled text Node, on the fly create the style
	 */
	public function fText(text:String, style:TextStyle):Element
	{
		var e = W.dom.newElement("p");
			e.innerHTML = text;
		applyStyle(e, style);
		return e;
	}//---------------------------------------------------;
	
	/**
	 * Create a text element and give it a CSS style
	 * @param	text The text
	 * @param	class_ CSS class name
	 * @return
	 */
	public function cText(text:String, class_:String):Element
	{
		var e = W.dom.newElement("p");
			e.innerHTML = text;
			e.className = class_;
		return e;
	}//---------------------------------------------------;
	
}// --


//====================================================;
// Styles 
//====================================================;

typedef TextStyle = {
	var color:String;
	var size:Int;
	@:optional var font:String;
	@:optional var bgColor:String;
	@:optional var shadow:String;
	@:optional var bold:String;
	@:optional var display:String;
	@:optional var padding:String;
	@:optional var align:String;
};//---------------------------------------------------;
