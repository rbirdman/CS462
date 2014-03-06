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
		
		provides get_location_data, get_constant_value, print
	}
	
	dispatch {
	}
	
	global {
		get_location_data = function(key) {
			//return value in entity variable
			value = ent:locationData.values([key]);
			value
		}
		get_constant_value = "Test Value Placed here";
		
		print = function(key) {
			ent:locationData.as("str")
		}
	}
	
	rule setup is active {
		select when web cloudAppSelected
		pre {
			my_html = <<
				<div id="main">Storage Info:</div>
				<div id="output"/>
			>>;
		}
		{
			SquareTag:inject_styling();
			CloudRain:createLoadPanel("Foursquare", my_html);
			
			notify("I am running", "from display mode");
			replace_html('#main', my_html);
			
		}
	}
	
	rule printData is active {
//		select when web cloudAppSelected
		select when foursquare login
		pre {
			data = print();
			
			data_html = <<
					<div id="storageInfo"><p>#{data}</p></div>
				>>;
		}
		{
			append('#main', data_html);
		}
	}
	
	rule checkEntityVariable is active {
		select when pds new_location_data
		
		if ent:locationData.isnull() then {
			send_directive('text') with body = "Setting variable";
		}
		fired {
			set ent:locationData {}
		}
	}
	
	rule add_location_item is active {
		select when pds new_location_data
		
		pre {
			key = event:attr("key");
			value = event:attr("value");
			
			mapValue = {};
		}
		{
			send_directive('text') with body = "storing in variable: key: ${key} val: ${value}"
									and key = key;
		}
		always {
//			set ent:locationData ent:locationData.put([key],value);
			set ent:locationData mapValue.put([key],value);
		}
	}
	
}