ruleset rotten_tomatoes {
	meta {
		name "Foursquare Checkins"
		description <<
			Hello World
			>>
		author "Ryan Bird"
		logging on
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
	// cs.kobj.net/sky/event/A91B1BA0-9B4A-11E3-9413-761EF81F7F35/5/foursquare/checkin
	global {
		
	}
	
	rule home is active {
		select when web cloudAppSelected
		pre {
			my_html = <<
				<div id="main">Checkin Info:</div>
			>>;
			
			my_form = <<
				<form id="form" onsubmit="return false">
					<input type="submit" value="Foursquare" />
				</form>
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
			append('#main', my_form);
			watch('#form', "submit");
		}
	}
	
	//The rule should store the venue, city, shout, and createdAt event attributes in entity variables.
	rule process_fs_checkin is active {
		select when foursquare checkin
		pre {
			venue = "Test Venue" + ent:count.as("str");
			city = "Test City" + ent:count.as("str");
			shout = "Test Shout" + ent:count.as("str");
			createdAt = "Test Created At" + ent:count.as("str");
		}
		{
			notify("Checkin received","from Foursquare");
		}
		fired {
			set ent:venue venue;
			set ent:city city;
			set ent:shout shout;
			set ent:createdAt createdAt;
			ent:count += 1 from 0;
		}
		
	}
	
	rule display_checkin is active {
		select when web cloudAppSelected
		
		pre {
			html = <<
				<p>Venue: #{ent:venue}</p>
				<p>City: #{ent:city}</p>
				<p>Shout: #{ent:shout}</p>
				<p>Created At: #{ent:createdAt}</p>
			>>;
		}
		{
			notify("Checkin received","Replacing html");
			replace_html("#checkinInfo", html);
		}
	}
	
	rule signinFoursquare {
		select when web submit "#form"
		pre {
			
		}
		{
			notify("Make Oauth call here","Allow for any user");
			notify("Cleared","Count");
		}
		fired {
			clear ent:count
		}
	}
}