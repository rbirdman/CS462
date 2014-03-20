ruleset Receiver {
	meta {
		name "Location Data"
		description <<
			Collect... the dataz
			>>
		author "Ryan Bird"
		logging on
		use module a169x701 alias CloudRain
		use module a41x196 alias SquareTag
	}
	
	dispatch {
	}
	
	global {
	}
	
	rule visual is active {
		select when web cloudAppSelected
		pre {
			my_html = <<
				<div id="main">Texting: #{ent:location}</div>
			>>;
		}
		{
			SquareTag:inject_styling();
			CloudRain:createLoadPanel("Foursquare: Location", {}, my_html);
			
			notify("I am running", "from display mode");
			replace_html('#main', my_html);
		}
	}
	
	rule nearby is active {
		select when location notification
		pre {
			loc = event:attr("location");
	
		}
		
		//within 10 kilometers
		if distance < 10 then {
			send_directive("Calculating");
		}
		fired {
			set ent:location lat;
		}
	}
}