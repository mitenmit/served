import std.stdio;

public import CRouter;

class Served{
	private CRouter _router;
	
	this(){
		writeln("Welcome to Served constructor");
	}
	
	private void init(){
	}
	
	private void defaultConfiguration(){
	}
	
	private void lazyRouter(){
		if (!this._router){
			this._router = new CRouter();
		}
	}
	
	private void handle(){
		if(!_router){
			writeln("Router not set up!");
			return;
		}
		//_router.handle();
	}
	
	
	public Served use(){
		
		return this;
	}
	
	public Object route(string path){
		this.lazyRouter();
		
		return new Object();
	}
	
}