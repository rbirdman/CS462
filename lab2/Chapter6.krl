ruleset HelloWorldApp {
  meta {
    name "Hello World"
    description <<
      Hello World
    >>
    author "Ryan Bird"
    logging off
    use module a169x701 alias CloudRain
    use module a41x196 alias SquareTag
  }
  dispatch {
  }
  global {
	getKey = function(key) {
		//replace & with = for splitting
		query = page:url("query").replace(re/&/, "=");
		queries = query.split(re/=/);
		index = queries.index(key);

		user = (index < 0) => "Monkey" | queries[index + 1];
		user
	};
  }
  
  rule exampley {
  	select when web pageview url re#exampley.com#
  	notify("Here you are")
  	notify("You are here")
  }
  
  rule heroku {
	 select when pageview '.*'
	 pre {
	 }
	 {
		alert("You are entering Heroku territory");
		notify("Heroku","Congratulations, You fired a notification on Heroku") with sticky = true;
	 }
  }
  
  rule HelloWorld is active {
    select when web cloudAppSelected
    pre {
        my_html = <<
            <h5>Hello, World!</h5>
        >>;
    }
    {
		alert("Stuff");
        notify("This is a notification","This is subtext");
        notify("This notification will stay","with sticky=true")
          with sticky=true;

        SquareTag:inject_styling();
        CloudRain:createLoadPanel("Hello World", {}, my_html);
    }
  }
  
  rule checkQuery is active {
	 select when pageview '.*'
	 pre {
//		  pagePath = page:url("path");
//		  pageQuery = page:url("query");
		  //pagePath = (pagePath eq "") => "Monkey" | pagePath;

		  name = getKey("name");
      count = ent:count;
		  //keyPairs = pageQuery.extract();
	 }

	 if ent:count < 5 then {
		  notify("Hello " + name, "Count = " + count) with sticky = true;
	 }
	 fired {
	   ent:count += 1 from 0;
   }
  }

  rule clearCount is active {
    select when pageview '.*'
    pre {
      clearIndex = page:url("query").match(re/clear/);
    }
    if clearIndex then {
      notify("Cleared Count", "Happily");
    }
    fired {
      clear ent:count;
    }
  }
}
