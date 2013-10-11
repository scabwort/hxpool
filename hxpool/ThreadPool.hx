package hxpool;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

/**
 * thread pool
 * @author Scott Lee
 */
class ThreadPool
{
	static private var _instance:ThreadPool = new ThreadPool();
	/**
	 * create Thread with argument
	 * @param	func			thread function while running in thread
	 * @param	arg				thread function' s argment
	 * @param	completeFunc	the function run in thread over
	 */
	static public function createThreadWidthArg(func:Dynamic->Dynamic, arg:Dynamic, completeFunc:Dynamic->Void):Void
	{
		_instance.run(func.bind(arg), completeFunc);
	}
	/**
	 * create Thread without argument
	 * @param	func			thread function while running in thread
	 * @param	completeFunc	the function run in thread over
	 */
	static public function createThread(func:Void->Dynamic, completeFunc:Dynamic->Void):Void
	{
		_instance.run(func, completeFunc);
	}
	/**
	 * check message from child thread, check is over
	 */
	static public function check():Void
	{
		_instance.checkThread();
	}
	
	var _pool:List<ThreadNode>;
	var _runPool:Map<Int, ThreadNode>;
	var _mainThread:Thread;
	
	public function new() 
	{
		_pool = new List<ThreadNode>();
		_runPool = new Map<Int, ThreadNode>();
		_mainThread = Thread.current();
		for (i in 0...10) 
		{
			_pool.push(new ThreadNode(_mainThread));
		}
	}
	/**
	 * get empty thread from _pool list, if not, create new
	 */
	function getEmptyThread():ThreadNode
	{
		if (_pool.length > 0)
		{
			return _pool.pop();
		}
		return new ThreadNode(_mainThread);
	}
	/**
	 * check child thread send message to main thread
	 */
	public function checkThread():Void
	{
		while (true)
		{
			var nodeKey:Int = Thread.readMessage(false);
			if (nodeKey == null) break;
			
			if (_runPool.exists(nodeKey))
			{
				var node:ThreadNode = _runPool.get(nodeKey);
				_runPool.remove(nodeKey);
				
				node.reset();
				_pool.push(node);
			}
		}
	}
	/**
	 * set run and complete function, prepare for running child thread
	 */
	public function run(func:Void->Dynamic, complete:Dynamic->Void):Void
	{
		var node:ThreadNode = getEmptyThread();
		if (node.run(func, complete))
		{
			_runPool.set(node.key, node);
		} else
		{
			_pool.push(node);
		}
	}
}