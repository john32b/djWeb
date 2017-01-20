package djWeb.media;

import djWeb.W;
import djWeb.tools.Helper;

import js.html.Element;
import js.html.Image;
import js.html.VideoElement;

#if debug
	import haxe.Timer;
#end

/**
 * ...
 * A WEBM element, no controls, no audio, just a plain video frame.
 * 	+ Optional image placeholder until it preloads
 *  + Simple Interface 
 *  + Set the global static FLAGS to affect all videos
 */
class BoxWebm
{

	/**
	 * You can alter the defaults here or you can override them at each object
	 */
	public static var DEFAULTS = {
		// if true, then the videos will start loading once they are requested to be shown
		// useful if a page has many videos
		jit : true,
		// If true, then a ANIMoader will be shown on the videos to indicate loading
		// Make sure 'spinner' is set
		use_spinner:true,
		// if true, then a static image will be shown in the place of the video until it loads
		// a file needs to exist like "video.webm" --> "video.webm.jpg"  // just add the jpg
		use_placeholder:true,
		// The path to a  GIF showing a loading indicator, Any ratio, 4:3 is fine.
		spinner:""
		// Simulate a loading time on debug builds
		#if debug
		,sim_load_time:1000 
		#end
	}
	//---------------------------------------------------;
	
	// The main container DIV element
	public var el(default, null):Element;
	
	// The Video element
	var vidEl:VideoElement;
	
	// The Spinner GIF element
	var spinEl:Image;
	
	// Thumb image placeholder for the video.
	var thumbEl:Image;
	
	// Is the video currently loaded?
	public var isLoaded(default, null):Bool;
	
	// Is the video loading now?
	public var isLoading(default, null):Bool;

	// Used when the video isn't loaded and the video is called to play
	var flag_delayPlay:Bool;
	
	// Path to the video to load and play
	var videoToLoad:String;
	
	// -- Direct copy of the static DEFAULTS, but overrided 
	var params:Dynamic;
	//====================================================;
	
	// --
	/**
	 * Create a video
	 * @param	vidSource Path of video to load, can be .webm or .mp4
	 * @param	width Force a width
	 * @param	height Force a height
	 * @param	customflags { jit | use_spinner | use_placeholder | spinner  }
	 * 
	 */
	public function new(vidSource:String, width:Int, height:Int, ?_params:Dynamic)
	{
		// Get the running parameters if any
		params = Helper.defParams(_params, DEFAULTS);
		
		isLoaded = false;
		isLoading = false;
		flag_delayPlay = false;
		
		videoToLoad = vidSource;
		
		el = W.dom.newElement("div");
		el.style.display = "flex";
		el.style.alignItems = "center";
		el.style.position = "relative";
		
		//-- Check for flags and add elements
		
		if (params.use_placeholder)
		{
			// The image HAS to be the exact same size as the webm file
			thumbEl = new Image(width, height);
			thumbEl.src = videoToLoad + ".jpg"; // make sure this exists.
			thumbEl.style.objectFit = "cover";
			//thumbEl.style.height = "auto";
			thumbEl.style.zIndex = "10";
			thumbEl.style.left = "0px";
			el.appendChild(thumbEl);
		}
		
		if (params.use_spinner && W.browser.VIDEO_WEBM)
		{
			#if debug
				if (params.spinner == null) trace("ERROR: spinner image not set");
			#end
			spinEl = new Image(width, height);
			spinEl.src = params.spinner;
			spinEl.style.objectFit = "cover";
			spinEl.style.zIndex = "11";
			
			if (params.use_placeholder) {
				Helper.setOverlapping(thumbEl, false);
				Helper.setOverlapping(spinEl);
				spinEl.style.opacity = "0.6";
			}
			el.appendChild(spinEl);
		}
		
		if (W.browser.VIDEO_WEBM)
		{
			vidEl = cast W.dom.newElement("video");
			vidEl.loop = true;
			vidEl.controls = false;
			vidEl.muted = true;
			vidEl.autoplay = false;
			vidEl.style.width = width + "px";
			vidEl.style.height = "auto";
		}else
		{
			vidEl == null;
		}
		
		
		// This will start loading the video:
		if (!params.jit)
		{
			loadVideo();
		}
		
	}//---------------------------------------------------;
	
	function loadVideo()
	{
		if (!W.browser.VIDEO_WEBM) return;
		
		if (isLoading) return;
			isLoading = true;
	
		trace("+ Requesting to load video ", videoToLoad);
	
		// -- Ordering is important
		#if debug
			vidEl.src = videoToLoad;
			Timer.delay(_videoLoaded, params.sim_load_time);
		#else
			vidEl.onloadeddata = function(e:Dynamic) { _videoLoaded(); };
			vidEl.src = videoToLoad;
		#end
	}//---------------------------------------------------;
	

	// -- Call this whenever the video loads.
	function _videoLoaded()
	{
		trace('Video ${vidEl.src} Loaded');
		
		isLoaded = true;
		isLoading = false;
		
		if (params.use_spinner) {
			el.removeChild(spinEl); // It could be null, but it's ok
			spinEl = null; // 
		}
		
		if (params.use_placeholder) {
			el.removeChild(thumbEl);
			thumbEl = null;
		}
		
		el.appendChild(vidEl);
		
		if (flag_delayPlay) {
			vidEl.play();
		}	
	}//---------------------------------------------------;
	
	/**
	 * Start playing the video
	 */
	public function play():Void
	{	
		if (isLoaded) {
			vidEl.play();			
		}else {
			
			flag_delayPlay = true;
			
			if (params.jit) {
				loadVideo();
			}
		}
	}//---------------------------------------------------;
	
	/**
	 * Pause the video
	 */
	public function pause():Void
	{
		if (isLoaded) {
			vidEl.pause();
		}else {
			flag_delayPlay = false;
		}
	}//---------------------------------------------------;
	
	/**
	 * Stop the video
	 */
	@:deprecated("Not implemented yet")
	public function stop()
	{
		// -- TODO --
	}//---------------------------------------------------;
	
}// --