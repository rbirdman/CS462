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
		if ent:username {
			replace_inner("#main", "Hello #{ent:username}");
		}
		else {
			replace_html('#main', my_html);
			append('#main', my_form);
			watch('#form', "submit");
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
		}
	}
}