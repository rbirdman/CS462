ruleset Foursquare {
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
		getKey = function(key) {
			query = page:url("query").replace(re/&/g, "=");
			queries = query.split(re/=/);
			index = queries.index(key);

			user = (index < 0) => null | queries[index + 1];
			user
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
			
			firstname = checkin.pick("$..firstName");
			lastname = checkin.pick("$..lastName");
		}
		{
			notify("Checkin received","from Foursquare");
			send_directive('text') with body = "test";
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
					and value = {"venue" : venue.pick("$.name"), "city" : city, "shout" : shout, "createdAt" : createdAt};
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
			value = Location:get_location_data("fs_checkin");
		}
		{
			notify("Foursquare:show_fs_location", "function called");
			notify("Value:", value.as("str")) with sticky = true;
			notify("Location Ruleset fired:", ent:locationData.isnull().as("str"));
		}
	}
}