import std.stdio;
import std.socket;

string CRLF = "\r\n";

class CHTTPServer{
	private Socket _socket;
	
	this(){
	}
	
	void openConnection(){
		_socket = new TcpSocket(AddressFamily.INET);
		_socket.bind(new InternetAddress("0.0.0.0", port));
		_socket.listen(8);
	}
	
	void closeConnection(){
		
		_socket.shutdown(SocketShutdown.BOTH);
		_socket.close();
	}
	
	void listen(int port = 80){
		writeln("Listening on port ", port, "...");
		
	}
}