ruleset location_data {
	//b502807x13.prod
	meta {
		name "Location Data"
		description <<
			Collect... the dataz
			>>
		author "Ryan Bird"
		logging on
		
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
		}
		{
			send_directive('text') with body = "storing in variable";
		}
		always {
			set ent:locationData ent:locationData.put([key],value);
		}
	}
	
}