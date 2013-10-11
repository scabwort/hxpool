package ;

import hxpool.ThreadPool;
import neko.Lib;

/**
 * ...
 * @author Scott Lee
 */

class Main 
{
	
	static function main() 
	{
		//for (i in 0...10) 
		//{
		//}
		ThreadPool.createThreadWidthArg(Test1, 1, Test1Over);
		ThreadPool.createThreadWidthArg(Test1, 100, Test1Over);
		ThreadPool.createThreadWidthArg(Test1, 200, Test1Over);
		
		while (true)
		{
			Sys.sleep(0.1);
			ThreadPool.check();
			trace("main trace");
		}
	}
	
	static private function Test1(idx:Int):String 
	{
		var sum:Float = 0;
		var len:Int = idx * 10000;
		for (i in 0...len) 
		{
			sum += Math.sin(Math.cos(i));
		}
		return "Test " + idx + " Data";
	}
	
	static private function Test1Over(data:Dynamic):Void 
	{
		ThreadPool.createThreadWidthArg(Test1, Std.parseInt(Std.string(data).split(" ")[1]) + 1, Test1Over); 
		trace("Test1 Over, " + data);
	}
}