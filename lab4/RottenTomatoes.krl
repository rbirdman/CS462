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
						body = result.pick("$.content");
						body
					}
		//http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=[your_api_key]&q=Toy+Story+3&page_limit=1
		getMovieData = function(title) {
					result =  http:get("http://api.rottentomatoes.com/api/public/v1.0/movies.json",
								{"apikey":key, "q":title, "page_limit": 1});
					body = result.pick("$.content").decode();
					movieArray = body.pick("$.movies");
					movie = movieArray[0];
					movie
				}
	}
	
	rule SquareTagForm is active {
		select when web cloudAppSelected
		pre {
			my_html = <<
				<div id="main"></div>
			>>;
			my_form = <<
					<p>Enter in a movie title:</p>
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
			append('#main', data_html);
			append('#main', my_form);
			watch('#form', "submit");
		}
	}
	
	
	rule clear_movie_info {
		select when web submit "#form"
		pre {
			title = event:attr("title");
			displayHTML = <<
				<p>Sorry. Could not find "#{title}"</p>
			>>;
		}
		{
			replace_inner("#movieInfo", "#{displayHTML}");
		}
	}
	
	//Avengers: http://www.imdb.com/title/tt0848228/?ref_=nv_sr_2
	//Thor 2: http://www.imdb.com/title/tt1981115/?ref_=nv_sr_1
	//Pirates 2: http://www.imdb.com/title/tt0383574/?ref_=tt_rec_tti
	
	//Toy Story 3, Finding Nemo, Batman Begins
	
	//Movie thumbnail,Title,Release Year,Synopsis,Critic ratings,and other data you find interesting. 
	rule obtain_rating {
		select when web submit "#form"
		pre {
			movieData = getMovieData(event:attr("title"));
			movieDataString = movieData.as("str");
			
			title = movieData.pick("$.title");
			synopsis = movieData.pick("$..synopsis");
			release_date = movieData.pick("$..release_dates.theater");
			criticRatings = movieData.pick("$..ratings");
			thumbnail = movieData.pick("$..posters.thumbnail");
			
			critic_rating = criticRatings.pick("$.critics_rating").as("str");
			audience_rating = criticRatings.pick("$.audience_rating").as("str");
			critic_score = criticRatings.pick("$.critics_score").as("str");
			audience_score = criticRatings.pick("$.audience_score").as("str");
			
			critics_consensus = movieData.pick("$..critics_consensus");
			movieRating = movieData.pick("$..mpaa_rating");
			runtime = movieData.pick("$..runtime");
			
			displayHTML = <<
					<p>Movie Data:</p>
					<h2 id=movie_title></h2>
					<p id=release_date></p>
					<p id=runtime">Runtime: #{runtime} minutes</p>
					<img id=thumbnail src=#{thumbnail}></img>
					<p id=synopsis></p>
					
					<table>
					<tr>
						<td width=25px></td>
						<td width=75px align="center">Critics</td> 
						<td width=75px align="center">Audience</td>
					</tr>
					<tr>
						<td>Rating</td>
						<td id=critic_rating align="center">#{critic_rating}</td> 
						<td id=audience_rating align="center">#{audience_rating}</td>
					</tr>
					<tr>
						<td>Score</td>
						<td id=critic_score align="center">#{critic_score}</td> 
						<td id=audience_score align="center">#{audience_score}</td>
					</tr>
					</table>
					
					<br>
					<p id=concensus></p>
					
					<p id=mpaaRating></p>
				>>;
		}
		if title then {
//			replace_inner("#movieInfo", "Movie Data: #{movieDataString} <br>Movie Title: #{title}<br>Synopsis: #{synopsis}");
			replace_inner("#movieInfo", "#{displayHTML}");
			
			replace_inner("#movie_title", "#{title}");
			replace_inner("#release_date", "Released: #{release_date}");
			replace_inner("#synopsis", "Synopsis: #{synopsis}");
			
			replace_inner("#concensus", "Critics Consensus: #{critics_consensus}");
			replace_inner("#mpaaRating", "Rated: #{movieRating}");
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