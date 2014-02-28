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
			checkin = event:attr("checkin").decode();
			venue = checkin.pick("$..venue");
			city = checkin.pick("$..city");
			shout = checkin.pick("$..shout");
			createdAt = checkin.pick("$..createdAt");
		}
		{
			notify("Checkin received","from Foursquare");
			send_directive('text') with body = "test";
		}
		fired {
			set ent:venue venue;
			set ent:city city;
			set ent:shout shout;
			set ent:createdAt createdAt;
			ent:count += 1 from 0;
			
			raise explicit event checkin_success;
		}
	}
	
	rule display_checkin is active {
		select when web cloudAppSelected
		
		pre {
			venue = ent:venue.as("str");
			city = ent:city.as("str");
			shout = ent:shout.as("str");
			createdAt = ent:createdAt.as("str");
			
			html = <<
				<p>Venue: #{venue}</p>
				<p>City: #{city}</p>
				<p>Shout: #{shout}</p>
				<p>Created At: #{createdAt}</p>
				<p>Count: #{ent:count}</p>
			>>;
		}
		{
			notify("Foursquare Venue:", stringValue);
			replace_html("#checkinInfo", html);
		}
	}
	
	//https://foursquare.com/oauth2/authenticate
    //?client_id=NEJBAKQFILH5P01MMGF4SCUKD21TWPOYWFUHKXFCEBXBR1NT
    //&response_type=code
    //&redirect_uri=https://squaretag.com/app.html#!/app/b502807x10/show
	
	rule signinFoursquare {
		select when web submit "#form"
		pre {
			url = "https://foursquare.com/oauth2/authenticate" +
				"?client_id=NEJBAKQFILH5P01MMGF4SCUKD21TWPOYWFUHKXFCEBXBR1NT" +
				"&response_type=code" +
				"&redirect_uri=https://squaretag.com/app.html#!/app/b502807x10/show";
		}
		{
			redirect(url);
//			notify("Make Oauth call here","Allow for any user");
//			notify("Cleared","Count");
		}
		fired {
			clear ent:count
		}
	}
	
//	rule retrieveAccessToken {
//		select when web cloudAppSelected
//		
//		pre {
//			code = getKey("code");
//		}
//		if code then {
//			notify("Code:", code);
//		}
//	}
	
}