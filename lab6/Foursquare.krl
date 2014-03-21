ruleset Foursquare {
	//b502807x11.prod
	meta {
		name "Foursquare Checkins"
		description <<
			Foursquare Checkin lab - Display the checkins
			>>
		author "Ryan Bird"
		logging on
		use module a169x701 alias CloudRain
		use module a41x196 alias SquareTag
		
		use module b502807x12 alias Examine
		use module b502807x13 alias Location
	}
	dispatch {
	}
	
	global {

		subscription_map = {
			"rlbird22-1@gmail.com": "9F4D38E8-AEE5-11E3-ACB1-6B87833561DC",
			"rlbird22-2@gmail.com": "5164B1F2-AEE4-11E3-9269-B66CD61CF0AC"
		};
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
			CloudRain:createLoadPanel("Foursquare", {}, my_html);
		
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
			checkinString = event:attr("checkin");
			checkin = checkinString.decode();
			venue = checkin.pick("$..venue");
			city = checkin.pick("$..city");
			shout = checkin.pick("$..shout");
			createdAt = checkin.pick("$..createdAt");
			
			lat = venue.pick("$.location.lat");
			long = venue.pick("$.location.lng");
			
			firstname = checkin.pick("$..firstName");
			lastname = checkin.pick("$..lastName");
		}
		{
			send_directive(venue.pick("$.name")) with checkin = venue.pick("$.name");
		}
		fired {
			set ent:checkin checkinString;
			set ent:venue venue;
			set ent:city city;
			set ent:shout shout;
			set ent:createdAt createdAt;
			set ent:fullname firstname + " " + lastname;
			ent:count += 1 from 0;
			
			raise pds event new_location_data
				with key = "fs_checkin"
					and value = {"venue" : venue.pick("$.name"), "city" : city, "shout" : shout, "createdAt" : createdAt, "lat": lat, "long": long};
		}
	}
	
	rule sendLocation is active {
		select when foursquare checkin
		foreach subscription_map setting (channelName,cid)
		pre {
			loc = ent:venue.pick("$.location");
			send_map = {"cid": cid, "location": loc};
		}
		{
			send_directive("Sending to pico") with value = send_map;
			event:send(send_map, "location", "notification")
				with attrs = {
					"location": loc
				};
		}
	}
	
	rule display_checkin is active {
		select when web cloudAppSelected
		
		pre {
			checkin = ent:checkin.as("str");
			venue = ent:venue.pick("$.name").as("str");
			city = ent:city.as("str");
			shout = ent:shout.as("str");
			createdAt = ent:createdAt.as("str");
			photoURL = ent:checkin.decode().pick("$..photo");
			name = ent:fullname;
			
			html = <<
				<p>Checkin: #{checkin}</p>
				<p>Venue: #{venue}</p>
				<img src=#{photoURL}></img>
				<p>Name: #{name}</p>
				<p>City: #{city}</p>
				<p>Shout: #{shout}</p>
				<p>Created At: #{createdAt}</p>
				
			>>;
		}
		{
			replace_html("#checkinInfo", html);
		}
	}
	
	rule show_fs_location is active {
		select when web cloudAppSelected
		pre {
			value = Location:get_location_data("fs_checkin").as("str");
			locationIsRunning = Location:get_constant_value;
			value2 = ent:locationData.values("fs_checkin");
			entityStr = ent:locationData.as("str");
		}
		{
			notify("Foursquare:show_fs_location", "function called");
			notify("Value:", value.as("str")) with sticky = true;
			notify("Value2:", value2.as("str")) with sticky = true;
			notify("Entity value:", entityStr) with sticky = true;
			notify("Constant:", locationIsRunning) with sticky = true;
		}
	}
}