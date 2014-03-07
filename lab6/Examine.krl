ruleset examine_location {
	//b502807x12.prod
	meta {
		name "Foursquare Checkins"
		description <<
			Foursquare Checkin lab - Display the checkins
			>>
		author "Ryan Bird"
		logging on
		use module a169x701 alias CloudRain
		use module a41x196 alias SquareTag
		
		use module b502807x13 alias location_data
	}
	dispatch {
	}
	
	global {
	}
	
	rule setup is active {
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
			CloudRain:createLoadPanel("Foursquare", {}, my_html);
		
			replace_html('#main', my_html);
			append('#main', data_html);
		}
	}
	
	rule show_fs_location is active {
		select when web cloudAppSelected
		pre {
			value = location_data:get_location_data("fs_checkin");
			constant = location_data:get_constant_value;
			valueType = value.typeof();
			valueStr = value.as("str");
			
			venueName = checkin.pick("$.venue");
			city = checkin.pick("$.city");
			shout = checkin.pick("$.shout");
			createdAt = checkin.pick("$.createdAt");
			
			html = <<
				<p>Venue: #{venueName}</p>
				<p>City: #{city}</p>
				<p>Shout: #{shout}</p>
				<p>Created At: #{createdAt}</p>
			>>;
		}
		{
			notify("Const:", constant) with sticky=true;
			notify("Venue:", venueName) with sticky=true;
			append("#main", "<p> Type:" + valueType + "<br>" + valueStr + "</p>");
			append("#main", html);
		}
	}
	
}