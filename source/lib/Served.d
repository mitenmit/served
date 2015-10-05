import std.stdio;

import _http_server;

public import CRouter;
public import CEvent;


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
		int offset = 0;
		string path = "/";
		
		return this;
	}
	
	public Object route(string path){
		this.lazyRouter();
		
		return new Object();
	}
	
	public void listen(ushort port = 80){
		auto server = new CHTTPServer();
		server.listen(port);
	}
	
}