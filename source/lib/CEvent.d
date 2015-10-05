import core.vararg;
import std.stdio;


alias void function(...) callbackType;

class CEvent
{
	callbackType[string] events;
	int eventsCount = 0;
	
	this(){
	}
	
	CEvent addListener(string type,  callbackType cb){
		if(type in events){
			events[type] = cb;
		}else{
			events[type] = cb;
			eventsCount++;
		}
		return this;
	}
	
	bool removeListener(string type){
		if(type in events){
			events.remove(type);
			return true;
		}
		
		return false;
	}
	
	bool emit(string type, ...){
		int argLength = _arguments.length;
		
		if(type in events){
			events[type]();
			/*
			switch(argLength){
				case 0:
					events[type]();
					break;
				case 1:
					events[type](_argptr);
					break;	
				case 2:
					events[type](_arguments[0], _arguments[1]);
					break;
				case 3:
					events[type](_arguments[0], _arguments[1], _arguments[2]);
					break;
				default:
					break;
			}
			*/
		}
		return true;
	}
}

unittest{
	void handler(...){writeln("String ");}
	
	auto e = new CEvent();

	e.addListener("start", &handler);
	e.addListener("start1", (...){
		writeln("Start 1");
	});
	e.removeListener("start");
	e.emit("start");
	e.emit("start1");
}