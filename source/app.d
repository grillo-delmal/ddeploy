import std.stdio;
import commandr;

struct Test {
	string a;
}

void main(string[] argsIn) {
	auto app = new Program("ddeploy", "1.0");
	app.summary = "build and deploy applications";
	auto args = app
		.add(new Command("build", "build project"))
		.add(new Command("new", "create new project"))
		.parse(argsIn);

}
