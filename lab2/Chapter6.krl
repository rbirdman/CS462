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
   
  }
  
  rule exampley {
  	select when web pageview url re#exampley.com#
  	notify("Here you are")
  	notify("You are here")
  }
  
  rule heroku is active {
	select when pageview ".*"
	notify("Heroku","Congratulations, You fired a notification on Heroku") with sticky = true;
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
		pagePath = page:url("path");
		pageQuery = page:url("query");
		pagePath = (pagePath eq "") => "Monkey" | pagePath
	}

	{
		notify("path", pagePath);
		notify("Hello", pageQuery);
	}
  }
}
