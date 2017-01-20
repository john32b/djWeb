package djWeb.other;

import djWeb.tools.Helper;
import haxe.Timer;
import js.Browser;
import js.html.Element;
import js.html.Image;
import js.Lib;


// Parameters pushed to elements
typedef _BgTileParams = {
	
	var imageUrl:String;
	var speed:Float;
	var angle:Float;
	var scrollx:Float;
	var scrolly:Float;
	var scrollxSpeed:Float;
	var scrollySpeed:Float;
	var imWidth:Int;
	var imHeight:Int;
};


/**
 * BGTileScroller
 * Tiles a background image on an element, and it animates it.
 * -----
 * Example:
 * 	
 * 	BgTileScroller.linkElement(bgElement, "media/bg1.png");
 *  note : the image should be preloaded and ready
 *  note : use W.loader to preload images.
 */
class BgTileScroller
{
	//====================================================;
	// STATIC
	//====================================================;
	
	// -- Defaults
	static var FPS:Int = 30;					// 
	static var DEFAULT_DIRECTION:Int = 45;	 	// Angle 0-360
	static var DEFAULT_SPEED:Float = 0.5;		// 
	
	// -- Internal
	
	// The main timer to update the scrolling effect
	static var timer:Timer = null;
	
	// a pool with all elements with tiled bg
	static var elements:Array<Element> = [];

	//---------------------------------------------------;
	
	
	// This is the update function that will be called multiple
	// times per second
	static function timerUpdate()
	{
		// Update all the elements style position
		for (i in elements)
		{
			var p:_BgTileParams = untyped(i._bgts);
			p.scrollx += p.scrollxSpeed;
			p.scrolly += p.scrollySpeed;
			
			// range loop
			p.scrollx = p.scrollx % p.imWidth;
			p.scrolly = p.scrolly % p.imHeight;

			i.style.backgroundPosition = '${p.scrollx}px ${p.scrolly}px';
		}
		
	}//---------------------------------------------------;
	
	// Stop rendering everything
	public static function stopTimer()
	{
		if (timer != null) {
			timer.stop();
			timer = null;
		}
	}//---------------------------------------------------;
	
	
	// Starts or restarts the timer
	public static function startTimer()
	{
		stopTimer();
		timer = new Timer(Math.floor(1000 / FPS ));
		timer.run = timerUpdate;
	}//---------------------------------------------------;
	
	
	// Set the direction vector for the background tile
	/**
	 * Set the direction and speed of an element
	 * WARNING: element must already be linked with linkElement();
	 * @param	el 
	 * @param	angle In Degrees
	 * @param	speed In pixels per update
	 */
	public static function setDir(el:Element, ?angle:Int, ?speed:Float)
	{
		var p:_BgTileParams = untyped(el._bgts);
	
		// parameter speed and angle values are set on element addition
		if (angle != null) p.angle = angle;
		if (speed != null) p.speed = speed;
		
		var rads:Float = p.angle * Math.PI / 180;	
	
		p.scrollxSpeed =  Math.cos(rads) * p.speed;
		p.scrollySpeed = -Math.sin(rads) * p.speed;
		
	}//---------------------------------------------------;
	
	
	// -- 
	// Quick set an element to an image without setting ID's or 
	// worrying about preloading
	@:deprecated("use LinkElement")
	public static function quickSetBG(el:Element, image:String)
	{
	}//---------------------------------------------------;
	
	
	/**
	 * Associate a dynamic list of elements, ( ID,element,[] ) to a background ID
	 * This will actually set the BG on those elements
	 * @param	source Dynamic elements, can be single element, array of elements or ID of elements
	 * @param	imageUrl
	 */
	public static function linkElement(source:Dynamic, imageUrl:String, ?angle:Int, ?speed:Float)
	{
		if (angle == null) angle = DEFAULT_DIRECTION;
		if (speed == null) speed = DEFAULT_SPEED;
		
		Helper.getElementsMultiAndDo(source, function(el:Element) {
			
			if (el == null) {
				trace("Error : Element is NULL!");
				return;
			}
			
			var o:_BgTileParams = {
				imageUrl:imageUrl, 
				speed:speed, angle:angle,
				scrollx:0, scrolly:0,
				scrollxSpeed:0, scrollySpeed:0,
				imWidth:0, imHeight:0
			};
			
			// -- Store the parameters inside the html element for easy reference
			untyped(el._bgts = o);
			
			// Calculate the direction vector once
			setDir(el);	
			
			elements.push(el);
		
			var im:Image = new Image();
				im.src = imageUrl; // TODO: if this doesn't work, get the image from the Loader.hx
				o.imWidth = im.width;
				o.imHeight = im.height;
				el.style.backgroundImage = 'url(${im.src})';
				el.style.backgroundRepeat = 'repeat';
					
			if (timer == null) {
				startTimer();
			}
			
		});
		
		if (timer != null) timerUpdate();
	}//---------------------------------------------------;
	
	
	/**
	 * Remove one or many elements
	 * @param	source 
	 */
	public static function removeElement(source:Dynamic)
	{
		Helper.getElementsMultiAndDo(source, function(i:Element) {
			try {
				elements.remove(i);
				i.style.backgroundImage = "";
				untyped(i._bgts = null);
			} catch (e:Dynamic) {
				// element not in list
				return;
			}
		});
		
		if (elements.length == 0) {
			timer.stop();
			timer = null;
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Remove a single imageUrl from the pool
	 * this also removes any elements associated
	 * @param	URL_
	 */
	static function removeimageUrl(URL_:String)
	{
		try {
			elements = elements.filter(function(e:Element) {
				if (untyped(e._bgts.imageUrl == URL_)) {
					untyped(e._bgts = null);
					e.style.backgroundImage = "";
					return false;
				} return true;
			});//--
						
			if (elements.length == 0) {
				timer.stop();
				timer = null;
			}
		}
	}//---------------------------------------------------;
	
}//-- end class --//