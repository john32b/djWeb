package djWeb.tools;
/**
 * ...
 */
class MathTools 
{
	// - References, set on 
	public var MAX_INT(default, null):Int;
	public var MAX_FLOAT(default, null):Int;

	// -- A random seed
	var randomSeed:Float;
	
	//====================================================;
	// 
	//====================================================;
	
	public function new() 
	{
		MAX_INT = untyped (Number.MAX_SAFE_INTEGER);
		MAX_FLOAT = untyped (Number.MAX_VALUE);
		
		// Randomize the seed a bit
		var d:Dynamic = untyped __js__("new Date()");
		randomSeed = untyped(d.getMilliseconds() * 2);
		randomSeed *= untyped(d.getHours());
		randomSeed -= (randomSeed * Math.random()) * 0.2;
		
		trace('MathTools | MaxInt=$MAX_INT | MaxFloat=$MAX_FLOAT | SEED = $randomSeed');
	}//---------------------------------------------------;
	
	/**
	 * Returns a pseudorandom integer between Min and Max, inclusive.
	 * @param	min
	 * @param	max
	 */
	public function rnd_int(Min:Int=0, Max:Int=-1):Int
	{
		if (Max == -1) Max = MAX_INT;
		
		if (Min == Max)
		{
			return Min;
		}
		else
		{
			// Swap values if reversed
			if (Min > Max)
			{
				Min = Min + Max;
				Max = Min - Max;
				Min = Min - Max;
			}
			
			return Math.floor( Min + (Max - Min + 1) * Math.random() );
		}
		
	}//---------------------------------------------------;
	
	/**
	 * Get a random float
	 * @param	Min
	 * @param	Max
	 * @return
	 */
	public function rnd_float(Min:Float = 0, Max:Float = 1):Float
	{
		
		if (Min == Max)
		{
			return Min;
		}
		else
		{
			// Swap values if reversed
			if (Min > Max)
			{
				Min = Min + Max;
				Max = Min - Max;
				Min = Min - Max;
			}
			
			return Min + (Max - Min) * Math.random();
		}
	}//---------------------------------------------------;
	
	
	/**
	 * Get an element from an array at random
	 */
	public function rnd_array(ar:Array<Dynamic>):Dynamic
	{
		return(ar[rnd_int(0, ar.length - 1)]);
	}//---------------------------------------------------;
	
	/**
	 * BORROWED FROM FLIXEL ::
	 * 
	 * Shuffles the entries in an array in-place into a new pseudorandom order,
	 * using the standard Fisher-Yates shuffle algorithm.
	 *
	 * @param  array  The array to shuffle.
	 * @since  4.2.0
	 */
	@:generic
	public function shuffle<T>(array:Array<T>):Void
	{
		var maxValidIndex = array.length - 1;
		for (i in 0...array.length)
		{
			var j = rnd_int(i, maxValidIndex);
			var tmp = array[i];
			array[i] = array[j];
			array[j] = tmp;
		}
	}//---------------------------------------------------;
	
}// --