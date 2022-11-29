function Speedtest_Run()
{
	// Test sign vs custom sign
	{
		global._speedtest_count = 8000;
		global._speedtest_values = array_create(global._speedtest_count);
		for (var i = 0; i < global._speedtest_count; ++i)
		{
			global._speedtest_values[i] = random_range(-1.0, +1.0);
		}
		
		Speedtest_TestCall(
			"sign(...) x " + string(global._speedtest_count),
			function ()
			{
				for (var i = 0; i < global._speedtest_count; ++i)
				{
					sign(global._speedtest_values[i]);
				}
			});
		Speedtest_TestCall(
			"float_sign(...) x " + string(global._speedtest_count),
			function ()
			{
				for (var i = 0; i < global._speedtest_count; ++i)
				{
					float_sign(global._speedtest_values[i]);
				}
			});
			
		// And check the final results
		for (var i = 0; i < 4; ++i)
		{
			debugLog(
				kLogOutput,
				"value[" + string(i) + "] = " + string(global._speedtest_values[i]) + ", "
					+ "sign()= " + string(sign(global._speedtest_values[i])) + ", "
					+ "float_sign()= " + string(float_sign(global._speedtest_values[i]))
				);
		}
	}
	
	// At the end, show the debug show
	Debug.Show();
}


function Speedtest_Start()
{
	global._speedtest_start = get_timer();
}
function Speedtest_Stop()
{
	var ending_time = get_timer();
	var delta = ending_time - global._speedtest_start;
	
	return delta / 1000.0;
}
function Speedtest_TestCall(identifier, call)
{
	Speedtest_Start();
	call();
	var runtime = Speedtest_Stop();
	
	debugLog(kLogOutput, "Speedtest [" + identifier + "]: " + string(runtime) + " ms");
}