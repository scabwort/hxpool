package hxpool;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end
/**
 * Thread node for pool
 * @author Scott Lee
 */

class ThreadNode
{
	static var SIGNAL_RUN		= 0;
	static var SIGNAL_COMPLETE	= 1;
	static var SIGNAL_DISPOS	= -1;
	
	static private var curIdx = 1;
	
	
	var _key:Int;
	var _main:Thread;
	var _handle:Thread;
	var _running:Bool;
	var _complete:Dynamic -> Void;
	var _run:Void->Dynamic;
	var _data:Dynamic;
	var _error:Dynamic;
	
	public var key(get,null) : Int;
	
	public function new(main:Thread) 
	{
		_key = curIdx++;
		_running = false;
		_main = main;
		_handle = Thread.create(threadRun);
	}
	
	/**
	 * thread running
	 */
	function threadRun() 
	{
		while (true)
		{
			var signal:Int = Thread.readMessage(true);
			if (signal == SIGNAL_RUN)
			{
				try 
				{
					_data = _run();
					_error = null;
				}catch (err:Dynamic)
				{
					_error = err;
				}
				_main.sendMessage(_key);
			}else if (signal == SIGNAL_DISPOS)
			{
				break;
			}
		}
		_main.sendMessage(SIGNAL_DISPOS);
	}
	/**
	 * get static key
	 */
	function get_key():Int
	{
		return _key;
	}
	/**
	 * run child thread
	 */
	public function run(func:Void->Dynamic, complete:Dynamic->Void):Bool
	{
		if (_running) return false;
		_running = true;
		
		_data = null;
		_run = func;
		_complete = complete;
		_handle.sendMessage(SIGNAL_RUN);
		return true;
	}
	/**
	 * resset and call complete function
	 */
	public function reset():Void 
	{
		if (_error == null && _complete != null)
		{
			_complete(_data);
		}
		_data = null;
		_running = false;
	}
	/**
	 * destroy thread
	 */
	public function dispose():Void
	{
		_handle.sendMessage(SIGNAL_DISPOS);
		_handle = null;
	}
}