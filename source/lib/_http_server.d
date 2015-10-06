import std.stdio;
import std.socket;
import std.conv;
import std.string;
import std.file;

string CRLF = "\r\n";

class CHTTPServer{
	private Socket _socket;
	
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
	
	string makeHTMLResponse(string html){
		string responseHeader = 
								"HTTP/1.1 200 OK"~CRLF~
								"Content-Type: text/html; charset=utf-8"~CRLF~
								"Content-Length: "~to!(string)(html.length)~CRLF~
								"Connection: keep-alive"~CRLF~
								"Server: served"~CRLF~
								CRLF~html;
		return responseHeader;						
	}
	
	private void parseRequestAndRespond(string request, Socket currSock){
		string[] lines = request.split(CRLF);
		
		if(request[0..3]=="GET"){
			string resource = lines[0].split(" ")[1];
			string contents="";
			string filename = (resource[resource.length-1] == '/' ? resource~"index" : resource)~".html";
			
			
			if(exists("public"~filename)!=0){
				contents = cast(immutable char[])read("public"~filename);
			}else{
				contents = "Resource not found";
			}
			
			writeln(filename);
			currSock.send( makeHTMLResponse(contents) );
			//currSock.send( makeHTMLResponse("<html><head><title>Test</title></head><body>Hello</body></html>") );
		}
	}
	
	void handleHTTP(){
		Socket currSock;
		uint bytesRead;
		ubyte[4096] buff;
	 
		while (true) {
			currSock = _socket.accept();
			
			while ((bytesRead = currSock.receive(buff)) > 0){
				string request = cast(string)buff[0..bytesRead];
				parseRequestAndRespond(request, currSock);
			}	
				
			currSock.close();
			buff.destroy();
		}
	}
	
	void listen(ushort port = 80){
		writeln("Listening on port ", port, "...");
		
		openConnection(port);
		handleHTTP();
	}
}