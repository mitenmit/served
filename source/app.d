import std.stdio;
import core.vararg;
import Served;

void handler(...){
	
	writeln("String ");
	
}

void main()
{
	auto served = new Served();
	
	served.listen(8080);
}
