ruleset rotten_tomatoes {
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
	
	//For Kynetx, the domain name is cs.kobj.net
	//The path is encoded as follows: /sky/event/<eci>/<eid>
	// /sky/event/<eci>/<eid>/<domain>/<type>
	//channel identifier (<eci>)
	//event ID  (<eid>) - a unique number assigned by the endpoint raising events to the
	//     event for correlation purposes. The endpoint is free to make the <eid> any
	//     value so long as it is URL encoded.
	
	//Name:Foursquare Checkins
	//ID:A91B1BA0-9B4A-11E3-9413-761EF81F7F35
	global {
		
	}
	
	rule home is active {
		select when web cloudAppSelected
		pre {
			my_html = <<
				<div id="main">Checkin Info:</div>
			>>;
			
			data_html = <<
							<div id="checkinInfo"/>
						>>;
		}
		{
			SquareTag:inject_styling();
			CloudRain:createLoadPanel("Hello World", {}, my_html);
		
			replace_html('#main', my_html);
			append('#main', data_html);
		}
	}
	
	//The rule should store the venue, city, shout, and createdAt event attributes in entity variables.
	rule process_fs_checkin {
		select when foursquare:checkin
		pre {
			ent:venue = "Test Venue";
			ent:city = "Test City";
			ent:shout = "Test Shout";
			ent:createdAt = "Test Created At";
		}
		{
			notify("Checkin received","from Foursquare");
		}
		
	}
	
	rule display_checkin {
		select when foursquare:checkin
		pre {
			html = <<
				<p>Venue: #{ent:venue}</p>
				<p>City: #{ent:city}</p>
				<p>Shout: #{ent:shout}</p>
				<p>Created At: #{ent:createdAt}</p>
			>>;
		}
		{
			replace_html("#checkinInfo", html);
		}
	}

}