ruleset location_data {
	meta {
		name "Location Data"
		description <<
			Collect... the dataz
			>>
		author "Ryan Bird"
		logging on
		
		provides get_location_data
	}
	
	dispatch {
	}
	
	global {
		get_location_data = function(key) {
			//return value in entity variable
			value = ent:locationData.values(key);
			value
		}
	}
	
	rule checkEntityVariable {
		select when pds new_location_data
		
		if ent:locationData.isnull() then {
			noop();
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
			noop();
		}
		always {
			set ent:locationData ent:locationData.put([key],value);
		}
	}
	
}