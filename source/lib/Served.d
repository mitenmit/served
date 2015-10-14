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
	
	public void handle(CHTTPRequest req, CHTTPResponse res){
		if(!_router){
			writeln("Router not set up!");
			return;
		}
		//_router.handle(req, res);
	}
	
	
	public Served use(){
		int offset = 0;
		string path = "/";
		
		return this;
	}
	
	CRoute route(string path){
		this.lazyRouter();
		
		return this._router.route(path);
		//return new Object();
	}
	
	public void listen(ushort port = 80){
		auto server = new CHTTPServer(this);
		server.listen(port);
	}
	
}