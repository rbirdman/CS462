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
			dataString = ent:location.encode();
			dataType = ent:location.typeof();
			my_html = <<
				<div id="main">Data Type: #{dataType}<br>
					Received data: #{dataString}}</div>
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
			loc = event:attr("location").decode();
			eventAttrs = event:attrs();
		}
		
		{
			send_directive("Pico received data") with location = loc;
		}
		fired {
			set ent:location loc;
			set ent:eventAttrs eventAttrs;
		}
	}
}