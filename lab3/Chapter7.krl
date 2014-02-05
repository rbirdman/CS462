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
		}
		{
			replace_html('#main', my_html);
		}
		
	}
}