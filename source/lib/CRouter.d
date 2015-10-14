class CRoute{
	this(string path){
	}
}

class CRouter{
	this(){
	}
	
	CRoute route(string path){
		CRoute route = new CRoute(path);
		
		return route;
	}
}