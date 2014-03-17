ruleset Texter {
	meta {
		name "Location Data"
		description <<
			Collect... the dataz
			>>
		author "Ryan Bird"
		logging on
		use module a169x701 alias CloudRain
		use module a41x196 alias SquareTag
		
		key twilio {
        	"username" : "ACe56ea419cff6af7c1db279762a68a308",
        	"password"  : "c6652ad3c8565325df4453326131a682"
    	}
	}
	
	dispatch {
	}
	
	global {
	}
	
	rule nearby is active {
		select when explicit location_nearby
		pre {
			message = "Pass off the lab, plz";
		}
		{
			twilio:sms(message) with
				to = "18588292034";
		}
	}
	
	rule nearby_Visual is active {
		select when web cloudAppSelected
		pre {
			message = "Pass off the lab, plz";
			my_html = <<
				<div id="main">Texting: #{message}</div>
			>>;
			post_url = "https://api.twilio.com/2010-04-01/Accounts/ACe56ea419cff6af7c1db279762a68a308/SMS/Messages.json"
		}
		{
			SquareTag:inject_styling();
			CloudRain:createLoadPanel("Foursquare: Location", {}, my_html);
			
			notify("I am running", "from display mode");
			replace_html('#main', my_html);
			
			twilio:sms(message) with
				To = "+18588292034" and
				From = "+18587629753";
//			http:post(post_url,
//				{"credentials":  {"username": "ACe56ea419cff6af7c1db279762a68a308",
//                                "password": "c6652ad3c8565325df4453326131a682"
//                                },
//               	"params":{From: "+18587629753", To: "+18588292034", Body: "message"}
//              });
			
			notify("Message", "Sent");
		}
	}
}