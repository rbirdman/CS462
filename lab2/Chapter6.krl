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

//		key + " temp val"
//		notify(key,index);
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
	 select when web cloudAppSelected
	 pre {
//		  pagePath = page:url("path");
//		  pageQuery = page:url("query");
		  //pagePath = (pagePath eq "") => "Monkey" | pagePath;

		  name = getKey("name");
      count = ent:count;
		  //keyPairs = pageQuery.extract();
	 }

	 if ent:count < 5 then {
//		  notify("path", pagePath);
		  notify("Hello", name) with sticky = true;
		  //ent:count += 1;
		  notify("Count", count);
	 }
	 fired {
	   ent:count += 1 from 0;
   }
	 //else {
	 //}
  }

  rule clearCount is active {
    select when web cloudAppSelected
    pre {
      containsClear = page:url("query").index("clear") >= 0;
    }
    if containsClear == true then {
      notify("Cleared Count", "Happily");
      //clear ent:count;
    }
    fired {
      clear ent:count;
    }
  }
}
