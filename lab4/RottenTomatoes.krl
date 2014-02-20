ruleset rotten_tomatoes {
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
		key="b4rk5kr5tbnqwtjygpved3m5"
		//http://api.rottentomatoes.com/api/public/v1.0.json?apikey=[your_api_key]
		getMovieList = function() {
						result = http:get("http://api.rottentomatoes.com/api/public/v1.0.json",
								{"apikey":key});
						body = result.pick("$.content");;
						body
					}
		//http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=[your_api_key]&q=Toy+Story+3&page_limit=1
		getMovieData = function(title) {
					result =  http:get("http://api.rottentomatoes.com/api/public/v1.0/movies.json",
								{"apikey":key, "q":title.replace(re/ /g, "+"), "page_limit": 1});
					result
//					body = result.pick("$.content");
//					body
//					movieArray = body.pick("$.movies");
//					movieArray
//					movie = movieArray[0];
//					movie
				}
	}
	
	rule SquareTagForm is active {
		select when web cloudAppSelected
	pre {
		my_html = <<
			<div id="main">Enter in a movie title:</div>
		>>;
		my_form = <<
				<form id="form" onsubmit="return false">
					<input type="text" name="title" />
					<input type="submit" value="Submit" />
				</form>
				>>;
		data_html = <<
						<div id="movieInfo"/>
					>>;
	}
	{
		SquareTag:inject_styling();
		CloudRain:createLoadPanel("Hello World", {}, my_html);
		
		replace_html('#main', my_html);
		append('#main', my_form);
		append('#main', data_html);
		watch('#form', "submit");
	}
}
	
	//Avengers: http://www.imdb.com/title/tt0848228/?ref_=nv_sr_2
	//Thor 2: http://www.imdb.com/title/tt1981115/?ref_=nv_sr_1
	//Pirates 2: http://www.imdb.com/title/tt0383574/?ref_=tt_rec_tti
	rule obtain_rating {
		select when web submit "#form"
		pre {
			result = getMovieData(event:attr("title"));
			resultString = result.as("str");
			movieData = result.pick("$.content");
//			movieData = getMovieData(event:attr("title"));
//			type = result.typeof(); //result is a hash
			movieArray = result.pick("$.content.movies");
			total = result.pick("$content.total").as("str");
			synopsis = result.pick("$..synopsis").as("str");
		}
		{
			replace_inner("#movieInfo", "HTTP Response: #{resultString}<br>JSON Response #{type}: #{movieData}<br>MovieArray: #{movieString}<br>Total: #{total}<br>Synopsis: #{synopsis}");
		}
		//throw event with title = title
	}
	
	rule display_rating {
		//select explicit event thrown by obtain_rating
		select when web submit "#form"
		pre {
			title = event:attr("title");
		}
		{
			notify("Movie title", title);
//			replace_inner("#movieInfo", "Title: #{title}");
		}
	}
	

}