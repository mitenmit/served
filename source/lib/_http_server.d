import std.stdio;
import std.socket;
import std.algorithm;
import std.conv;
import std.string;
import std.file;
import std.array;
import std.regex;
import std.json;

string CRLF = "\r\n";

class CHTTPServer{
	private Socket _socket;
	
	private int _maxConnections = 60;
	
	this(){
	}
	
	void openConnection(ushort port){
		_socket = new TcpSocket(AddressFamily.INET);
		_socket.bind(new InternetAddress("0.0.0.0", port));
		_socket.listen(10);
	}
	
	void closeConnection(){
		
		_socket.shutdown(SocketShutdown.BOTH);
		_socket.close();
	}
	
	string handleJson(string contents){
		string result = "";
		string part;
		auto ctr = ctRegex!(`\<\?json*|\?\>*`);
		auto parsed = split(contents, ctr);
		
		if(parsed.length > 1){
			int len = (parsed.length+1) / 2;
			for(int i = 0; i<len; i++ ){
				if(i<len-1){
					JSONValue j = parseJSON(parsed[i*2+1]);
					
					if("include" in j.object){
						if(exists("public"~j["include"].str)!=0){
							part = cast(immutable char[])read("public"~j["include"].str);
						}else{
							part = "File not found";
						}
						
						result ~= parsed[i*2]~part;
					}
				}else{
					result ~= parsed[i*2];
				}	
			}
		}else{
			result = contents;
		}
			
		return result;
	}
	
	string makeResponse(string src, string type){
		string responseHeader = 
								"HTTP/1.1 200 OK"~CRLF~
								"Content-Type: "~type~"; charset=utf-8"~CRLF~
								"Content-Length: "~to!(string)(src.length)~CRLF~
								"Connection: keep-alive"~CRLF~
								"Server: served"~CRLF~
								CRLF~src;
		return responseHeader;						
	}
	
	void extractLinks(string html){
		auto ctr = ctRegex!(`\<a(.*)?href=['|"](.*)['|"]`);
		
		foreach(m; matchAll(html, ctr)){
			writeln("Location: ", m[2]);
		}
	}
	
	private void parseRequestAndRespond(string request, Socket currSock){
		string[] lines = request.split(CRLF);
		
		if(request[0..3]=="GET"){
			string resource = lines[0].split(" ")[1];
			string contents="";
			string filename = resource;
			string type="text/html";
			
			string ext = "";
			string params = "";
			bool extMode = false;
			bool paramsMode = false;
			
			//auto ctr = ctRegex!(`^(\/\/?(?!\/)[^\?#\s]*)(\?[^#\s]*)?$`);
			//auto parsed = matchAll(resource, ctr);
			//writeln(request);
			
			for(int i=0;i<resource.length;i++){
			
				if(resource[i]=='?'){
					extMode = false;
					paramsMode = true;
				}
				
				if(resource[i]=='.') extMode = true;
				
				if(extMode)	ext ~= resource[i];
				if(paramsMode && resource[i]!='?') params ~= resource[i];
			}
			
			if( ext.length > 0 ){
				if(ext==".png") type="image/png";
				if(ext==".jpg") type="image/jpeg";
				if(ext==".jpeg") type="image/jpeg";
			}else{
				filename = (resource[resource.length-1] == '/' ? resource~"index" : resource)~".html";
			}
			
			
			if(exists("public"~filename)!=0){
				contents = cast(immutable char[])read("public"~filename);
			}else{
				contents = "Resource not found";
			}
			
			writeln("Links:");
			extractLinks(contents);
			
			writeln("Serving ", filename);
			currSock.send( makeResponse(/*contents*/ handleJson(contents), type) );
		}
	}
	
	void handleHTTP(){
		Socket[] sockets;
		Socket currSock;
		uint bytesRead;
		ubyte[4096] buff;
		
		/*
		while (true) {
			currSock = _socket.accept();
			
			while ((bytesRead = currSock.receive(buff)) > 0){
				string request = cast(string)buff[0..bytesRead-1];
				parseRequestAndRespond(request, currSock);
			}	
				
			currSock.close();
			buff.destroy();
		}
		*/
		
		auto sset = new SocketSet(_maxConnections + 1);
		
		for (;; sset.reset()) {
			sset.add(_socket);
			foreach (each; sockets)	sset.add(each);
			
			// Update socket set with only those sockets that have data
			// avaliable for reading. Options are for read, write,
			// and error.
			Socket.select(sset, null, null);
			
			// Read the data from each socket remaining, and handle the request.
			
			for (int i = 0; ; i++) {
NEXT:
				if (i == sockets.length) break;
				
				if (sset.isSet(sockets[i])) {
					int read = sockets[i].receive(buff);
					
					if (Socket.ERROR == read) {
						debug writeln("Connection error.");
						goto SOCK_DOWN;
					} else if (read == 0) {
						debug {
							try {
								// If the connection closed due to an error, remoteAddress() could fail.
								writefln("Connection from %s closed.", sockets[i].remoteAddress().toString());
							} catch (SocketException) {
								writeln("Connection closed.");
							}
						}
SOCK_DOWN:
						sockets[i].close(); //Release socket resources now.
 
						// Remove from socket from sockets, and id from threads.
						if (i != sockets.length - 1) sockets[i] = sockets.back;
						
						sockets.length--;
						
						debug writeln("\tTotal connections: ", sockets.length);
						goto NEXT; // -i- is still the NEXT index.
					} else {
						debug
							writefln("Received %d bytes from %s:"
									 ~ "\n-----",
									 read, sockets[i].remoteAddress().toString());
 
						//Handle the request
						string request = cast(string)buff[0..read-1];
						parseRequestAndRespond(request, sockets[i]);
						//sockets[i].send(buf[0 .. read]);
						writeln("");
					}
				}	
			}
			
			// Connection request.
			if (sset.isSet(_socket)) {
				Socket sn;
				try {
					if (sockets.length < _maxConnections) {
						sn = _socket.accept();
						debug writefln("Connection from %s established.", sn.remoteAddress().toString());
						assert(sn.isAlive);
						assert(_socket.isAlive);
						sockets ~= sn;
						debug writefln("\tTotal connections: %d", sockets.length);
					} else {
						sn = _socket.accept();
						debug writefln("Rejected connection from %s;"
									   ~ " too many connections.",
									   sn.remoteAddress().toString());
						assert(sn.isAlive);
						sn.close();
						assert(!sn.isAlive);
						assert(_socket.isAlive);
					}
				} catch (Exception e) {
					debug writefln("Error accepting: %s", e.toString());
					if(sn) sn.close();
				}
			}
			
		}
		
	}
	
	void listen(ushort port = 80){
		writeln("Listening on port ", port, "...");
		
		openConnection(port);
		handleHTTP();
	}
}