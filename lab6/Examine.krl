ruleset examine_location {
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
	
	rule show_fs_location is active {
		select when web cloudAppSelected
		pre {
//			value = location_data:get_location_data("fs_checkin");
		}
		{
			notify("show_fs_location", "function called");
		}
	}
	
}