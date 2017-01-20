package djWeb.other;

import djWeb.tools.Helper;
import haxe.Timer;
import js.Browser;
import js.html.Element;


/* ------------------------------------------
 * Creates a collection of autotext elements
 * Add elements here, and it will process them sequentially.
 */
class AutoTextGroup
{
	// Call this when all elements animate
	public var onComplete:Void->Void = null;
	// --
	var elements:Array<AutoText>;
	
	/*
	 * A dynamic source of elements
	 **/
	public function new(?source:Dynamic,?speed:Int)
	{
		elements = [];
		if (source != null) {
			add(source, null, speed);
		}
	}//---------------------------------------------------;
	
	/**
	 * Adds an element, or source of elements to the queue.
	 * @param el Element ID or Element
	 * @param text, set Text for the elements, null for same text as element
	 * @param speed, speed in which the letters will appear
	 */
	public function add(source:Dynamic,?text:String,?speed:Int)
	{
		Helper.getElementsMultiAndDo(source, function(el:Element) {
			if (el != null)
				elements.push(new AutoText(el, text, speed));
		});
		
	}//---------------------------------------------------;

	/** 
	 * Start animating the queue
	 * @param delayBetween In Milliseconds, apply a delay between animations. 0 for back to back
	 * @param onComplete Call this function when the queue completes
	 **/
	public function start(delayBetween:Int = 0, ?onComplete_:Void->Void)
	{
		if (onComplete_ != null) onComplete = onComplete_;
		
		//Just in case
		if (elements.length == 0)
		{
			if (onComplete != null) onComplete();
			return;
		}
		
		if (delayBetween > 0)
		{
			// Create a timer that runs every X
			var t = new Timer(delayBetween);
			
			t.run = function() {
				
				if (elements.length == 1)
				{
					// Add the oncomplete callback to the last element only
					elements.shift().start(function() {
						if (onComplete != null) onComplete();
					});
					t.stop();
					t = null;
				}
				else
				{
					elements.shift().start();
				}
			}//-timer end
		}
		else
		{
			elements.shift().start(_backToBack_onAnimComplete);
		}
		
	}//---------------------------------------------------;
		
	// --
	private function _backToBack_onAnimComplete()
	{
		if (elements.length == 0) {
			if (onComplete != null) onComplete();
			return;
		}
		else {
			elements.shift().start(_backToBack_onAnimComplete);
		}
	}//---------------------------------------------------;
	
}//-- end --//




/* -------------------------------------------
 * Usage:
 * ------
 * # textElement must exist
 * # create a new autotext handler to animate the textelement
 * var at = new AutoText(textElement,"Text To Display",100);
 *     at.start(function(){ trace("Complete!";} );
 * 
 * --
 * 
 *  # Get DOM elements el1 and el2 and immidiately 
 *  # start animating then to the text they already have
 * var el1:Element = getElementById(....);
 * var el2:Element = getElementById(....);
 * AutoText.addAndGo([el1,el2] ,function(){trace("All complete");});
 * 
 * 
 **/
//@:expose("AutoText")
class AutoText 
{
	// Minimum speed the effect can be
	inline static var minSpeed:Int = 14;
	// Decrease speed per iteration by this amount (speed * friction)
	inline static var friction:Float = 0.93;
	
	// Call this when ..
	public var onAnimationComplete:Void->Void;

	var element:Element;
	var fullText:String;
	
	var currentPos:Int;
	var maxLetters:Int;
	var speed:Int;
	
	//---------------------------------------------------;

	// NOTE:
	// If a text is set, this automatically changes the element's inner Text
	
	/**
	 * Prepares an element to be animated.
	 * @param	appliedElement 
	 * @param	inText The text to display
	 * @param	inSpeed Speed in miliseconds, smaller is faster
	 */
	public function new(appliedElement:Element,?inText:String,inSpeed:Int = 100) 
	{
		element = appliedElement;
		
		if (inText == null) {
			fullText = element.innerText;
		}
		else if (inText == "") {
			fullText = "--NOT SET--";
		}else {
			fullText = inText;
		}
		
		//trace("fulltext set to ", fullText);
		element.innerText = "";
		
		currentPos = 0;
		maxLetters = fullText.length;
		speed = inSpeed;
	}//---------------------------------------------------;
	
	/**
	 * Start animating the element
	 * @param onComplete Optional Call when it's done
	 */
	public function start(?onComplete:Void->Void):Void
	{
		if (onComplete != null) 
			onAnimationComplete = onComplete;
		
		Timer.delay(onTick, speed);
	}//---------------------------------------------------;
	
	
	function onTick():Void
	{
		element.innerText = fullText.substr(0, currentPos++);
		
		if(speed > minSpeed)
			speed = Math.ceil(speed * friction);
			
		if (currentPos > maxLetters)  
		{
			if (onAnimationComplete != null)
				onAnimationComplete(); 
		
		} else Timer.delay(onTick, speed);
		
	}//---------------------------------------------------;


	//====================================================;
	// STATIC 
	//====================================================;
		
	// Some Quick functions to create autotextgroups on the fly
	static public function addAndGo(source:Dynamic, ?onComplete:Void->Void, ?delay:Int):AutoTextGroup
	{
		var g = new AutoTextGroup(source);
		g.start(delay, onComplete);
		return g;
	}//---------------------------------------------------;
	
	// ideas;
	// static public function FREEZE_ALL()
	
	
}//-- end --//