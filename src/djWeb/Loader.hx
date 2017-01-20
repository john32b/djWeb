package djWeb;
import js.Browser;
import js.html.Image;
import js.html.XMLHttpRequest;

/**
 * Preloads images and other things
 * 
 * + Callbacks
 * - No error handling
 * + Quick and Simple
 * 
 */
class Loader
{
	// -- Static Global 
	// -- Manually set before anything
	public var MAX_CONCURRENT:Int = 3;
	
	// -- Internal
	var callback_onLoad:Void->Void;
	var callback_onError:Void->Void; // General Error, no details
	
	var num_totalItems:Int;
	var itemsWaiting:Array<Dynamic> = [];
	var itemsLoading:Array<Dynamic> = [];
	var itemsLoaded:Array<Dynamic> = [];
	
	// -- Public
	public var isLoaded(default, null):Bool;
	
	// Hold Items loaded with keys in a hash for easy retrieval
	public var bank:Map<String,Dynamic>;
	
	//====================================================;
	// 
	//====================================================;
	public function new()
	{
		reset();
	}//---------------------------------------------------;
	
	/**
	 * Force reset to use this again
	 * Stops loading if already loading
	 */
	public function reset()
	{
		num_totalItems = 0;
		callback_onLoad = null;
		isLoaded = false;
		
		while (itemsWaiting.length > 0) {
			itemsWaiting.pop();
		}
		
		while (itemsLoading.length > 0) {
			var item = itemsLoading.pop();		
			item.onload = null;
			if (item.type_ == "json") 
			{
				item.abort(); // abort the request
			}
		}
		
		itemsLoaded = [];
		bank = new Map();
		
	}//---------------------------------------------------;
	
	
	/**
	 * Preload an image, call start() to actually start loading
	 * @param	file
	 */
	public function addImage(url:String)
	{
		var im:Dynamic = new Image();
			im.type_ = "image";
			im.src_ = url;
			im.onload = function() { onItemLoaded(im); };
			
		itemsWaiting.push(im);
		num_totalItems++;
		
		// trace("- Adding Image to the queue, waiting : ",itemsWaiting.length);
	}//---------------------------------------------------;
	
	/**
	 * Prepare to load a JSON file,
	 * Also put it into the cache so you can retrieve it later
	 * @param	url 
	 * @param	key Unique SID for
	 */
	public function addJSON(url:String, key:String)
	{
		var file = new XMLHttpRequest();
		untyped(file.type_ = "json");
		untyped(file.key_ = key);
		file.responseType = cast 'json';
		file.open('get', url, true);
		file.onload = function() {
			if (file.status == 200) {
				onItemLoaded(file);
			}else {
				trace("Error: Failed to load JSON", file.responseURL);
			}
		};
		
		itemsWaiting.push(file);
		num_totalItems++;
	}//---------------------------------------------------;
		

	/**
	 * Start loading the queue
	 * @param	callback_ When everything is loaded
	 */
	public function start(?callback_:Void->Void, ?callbackError_:Void->Void)
	{
		callback_onError = callbackError_;
		callback_onLoad = callback_;
		var nn = MAX_CONCURRENT;
		while (nn-->0) {
			if (itemsWaiting.length >= 0) processQueue(); else break;
		}
	}//---------------------------------------------------;

	/**
	 * Autocalled, one item is loaded,
	 * load the next item.
	 */
	private function onItemLoaded(item:Dynamic)
	{
		item.onload = null;
		itemsLoaded.push(item);
		
		switch(item.type_)
		{
			case "json":
					bank.set(item.key_, item.response);
					if (item.response == null)
					{
						trace("Error Parsing JSON", item.responseURL);
						if (callback_onError != null) callback_onError();
						// Continue loading.
					}
					
			case "image":
				// Do nothing
				
			default:
		}
		
		processQueue();
	}//---------------------------------------------------;
	
	/**
	 * Load the next item on the queue, 
	 * If no more items, finalize and callback
	 */
	private function processQueue():Void
	{
		if (itemsWaiting.length == 0 && num_totalItems == itemsLoaded.length)
		{
			isLoaded = true;
			if (callback_onLoad != null) callback_onLoad();
			
		}else {
			
			// Process the next item to load
			var item = itemsWaiting.pop();
			
			if (item == null)
			{
				return; // No more items on queue
			}
			
			if (item.type_ == "image")
			{
				item.src = item.src_; // Starts loading the image
			}else
			
			if (item.type_ == "json")
			{
				item.send(null); // Starts loading the URL
			}
				
			// TODO:
			// - Other Item Types, such as Data or XML etc..
		}
	}//---------------------------------------------------;
	
}// --