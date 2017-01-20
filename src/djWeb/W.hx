package djWeb;
import djWeb.tools.BrowserInfos;
import djWeb.tools.DomTools;
import djWeb.tools.MathTools;
import djWeb.tools.TextTools;

/**
 * W (djWeb) Global object
 * Main static class object offering access to multiple components
 * ...
 * @author JohnDimi
 */
@:expose("W") // Optional Debug
class W
{
	// -- Global general purpose loader
	// This is the loader some djWeb components will access
	// if they rely on preloaded data
	public static var loader:Loader;
	
	// -- Provides INFOS
	public static var browser:BrowserInfos; /// Rename to Browser Tools?
	
	// -- Dom Tools
	public static var dom:DomTools;
	
	// -- Pointer to the main top container
	// -- WebMain sets this directly
	public static var main:MainFrame;
	
	
	// -- Text Tools
	public static var text:TextTools;
	
	// -- Math and Random
	public static var math:MathTools;
	
	//====================================================;
	// 
	//====================================================;
	public static function init()
	{
		if (dom != null) return; // Already initialized
		
		dom = new DomTools();
		loader = new Loader();
		browser = new BrowserInfos();
		text = new TextTools();
		math = new MathTools();
	}//---------------------------------------------------;

	
}