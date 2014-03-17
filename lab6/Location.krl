ruleset location_data {
	//b502807x13.prod
	meta {
		name "Location Data"
		description <<
			Collect... the dataz
			>>
		author "Ryan Bird"
		logging on
		use module a169x701 alias CloudRain
		use module a41x196 alias SquareTag
		
		provides get_location_data, get_constant_value, print, latitude, longitude
	}
	
	dispatch {
	}
	
	global {
		get_location_data = function(key) {
			app:locationData.pick("$.." + key)
		}
		get_constant_value = "Test Value Placed here";
		latitude = 0;
		longitude = 0;
		
		print = function(key) {
			app:locationData.as("str")
		}
	}
	
	rule setup is active {
		select when web cloudAppSelected
		pre {
			my_html = <<
				<div id="main">Storage Info:</div>
			>>;
		}
		{
			SquareTag:inject_styling();
			CloudRain:createLoadPanel("Foursquare: Location", {}, my_html);
			
			notify("I am running", "from display mode");
			replace_html('#main', my_html);
		}
	}
	
	rule printData is active {
		select when web cloudAppSelected
		pre {
			dataType = app:locationData.typeof();
			dataStr = app:locationData.encode();
			
			data_html = <<
					<div id="storageInfo"><p>Type: #{dataType}<br>#{dataStr}</p></div>
					<div id="UpdateSource">This will show in UI</div>
				>>;
		}
		{
			append('#main', data_html);
		}
	}
	
	rule add_location_item is active {
		select when pds new_location_data
		
		pre {
			key = event:attr("key");
			value = event:attr("value");
			
			lat = value.pick("$.lat");
			long = value.pick("$.long");
			
			mapValue = {};
		}
		{
//			latitude = lat;
//			longitude = long;
			send_directive(key) with location = value;
		}
		always {
//			set ent:locationData ent:locationData.put([key],value);
			set app:locationData mapValue.put([key],value);
//			set app:latitude lat;
//			set app:longitude long;
		}
	}
	
	//A899BB34-AAE8-11E3-A993-F2B6EFAFB119
	//https://cs.kobj.net/sky/event/A899BB34-AAE8-11E3-A993-F2B6EFAFB119/92673593271/location/current?lat=500&long=500
}