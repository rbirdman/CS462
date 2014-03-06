ruleset Lab5App {
  meta {
    name "Lab 5 Foursquare Checkin"
    description <<
      Lab 5 Foursquare Checking - CS 462
    >>
    author "Jason Dobry"
    logging off
    use module a169x701 alias CloudRain
    use module a41x196  alias SquareTag
  }
  dispatch {
   
  }
  global {
   
  }
  rule create_panel {
    select when web cloudAppSelected
    pre {
      html = <<
        <h1>Last Checkin</h1>
        <div id="checkin"></div>
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Lab 5 Foursqaure", {}, html);
    }
  }
  rule process_fs_checkin {
    select when foursquare checkin
    pre {
      rawCheckinData = event:attr("checkin").decode();
      checkin = rawCheckinData.decode();
      venue = checkin.pick("$.venue.name");
      city = checkin.pick("$.venue.location.city");
      state = checkin.pick("$.venue.location.state");
    }
    every {
      emit <<
        console.log(rawCheckinData);
        console.log(checkin);
      >>;
    }
    fired {
      set ent:checkin checkin;
      set ent:name name;
      set ent:venue venue;
      set ent:city city;
      set ent:state state;
    }
  }
  rule show_data {
    select when cloudAppSelected
    pre {
      name = ent:name;
      venue = ent:venue;
      city = ent:city;
      state = ent:state;
      checkin = ent:checkin;
      html = <<
        <ul>
          <li>Venue: #{venue}</li>
          <li>City: #{city}, #{state}</li>
        </ul>
      >>;
    }
    {
      replace_inner("#checkin", html);
      emit <<
        console.log(checkin);
        console.log(city);
      >>;
    }
  }
}