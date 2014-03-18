ruleset Nearby {
	meta {
		name "Location Data"
		description <<
			Collect... the dataz
			>>
		author "Ryan Bird"
		logging on
		use module a169x701 alias CloudRain
		use module a41x196 alias SquareTag
		
		use module b502807x13 alias Location
	}
	
	dispatch {
	}
	
	global {
		r90   = math:pi()/2;
		rEk = 6378;
	}
	
	rule listener is active {
		select when location current_loc
		
		pre {
			lat = event:attr("lat");
			long = event:attr("long");
			
			x = lat - Location:latitude();
			y = long - Location:longitude();
			
			distance = math:great_circle_distance(long,r90 - lat, y,r90 - x, rEk);
		}
		{
			send_directive("Listening") with
				x = x and
				y = y and
				distance = distance;
		}
		
	}
	
	//https://cs.kobj.net/sky/event/A899BB34-AAE8-11E3-A993-F2B6EFAFB119/92673593271/location/current?lat=500&long=500
	rule nearby is active {
		select when location current_loc
		pre {
			lat = event:attr("lat");
			long = event:attr("long");
			
			x = lat - Location:latitude();
			y = long - Location:longitude();
			
//			distance = math:sqrt(x*x + y * y);
			distance = math:great_circle_distance(long,r90 - lat, y,r90 - x, rEk);
		}
		
		//within 10 kilometers
		if distance < 10 then {
			send_directive("Calculating");
		}
		fired {
			raise explicit event location_nearby
				with distance = distance;
			set ent:last_lat lat;
			set ent:last_long long;
		}
		else {
			raise explicit event location_far;
		}
	}
	
	rule display is active {
		select when web cloudAppSelected
		pre {
			
			my_html = <<
					<div id="main">Last Location: #{ent:last_lat}:#{ent:last_long}
					<br>Last Checkin: #{Location:latitude()}:#{Location:longitude()}</div>
				>>;
		}
		{
			SquareTag:inject_styling();
			CloudRain:createLoadPanel("Foursquare: Location", {}, my_html);
		}
	}
	
}