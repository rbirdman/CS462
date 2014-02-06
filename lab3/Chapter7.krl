ruleset WebForm {
	meta {
		name "Hello World"
		description <<
			Hello World
			>>
		author "Ryan Bird"
		logging off
		use module a169x701 alias CloudRain
		use module a41x196 alias SquareTag
	}
	dispatch {
	}
	global {
	}
	
	rule show_form {
		select when pageview '.*'
		pre {
			my_html = << <div id="main">Here is my form</div> >>;
			my_form = <<
				<form id="form" onsubmit="return false">
					<input type="text" name="first" />
					<input type="text" name="last" />
					<input type="submit" value="Submit" />
				</form>
				>>;
		}
		//if ent:username eq 0 then {
		if ent:username.isnull() then {
			replace_html('#main', my_html);
			append('#main', my_form);
			watch('#form', "submit");
			notify("Fill out form", "Please");
		}
	}

	rule say_hello {
		select when pageview '.*'
		pre {
			my_html = << <div id="main">Here is my form</div> >>;
		}
		//if ent:username neq 0 then {
		if not ent:username.isnull() then {
			replace_html('#main', my_html);
			replace_inner("#main", "Hello #{ent:username}");
			notify("Hello", ent:username);
		}
	}
	
	rule respond_submit {
		select when web submit "#form"
		pre {
			firstname = event:attr("first");
			lastname = event:attr("last");
			username = firstname + " " + lastname;
		}
		replace_inner("#main", "Hello #{username}");
		fired {
			set ent:username username;
			set ent:firstname firstname;
			set ent:lastname lastname;
		}
	}
	
	rule clear_name {
		select when pageview re#\?clear=1#

		notify("Username", "cleared")
		always {
			//clear ent:username;
			set ent:username nil;
			clear ent:firstname;
			clear ent:lastname;
		}
	}
}