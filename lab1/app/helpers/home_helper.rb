module HomeHelper
	#$current_user = nil
	
	#@@current_user = ""
	def current_user
		#@@current_user
		cookies[:current_user]
	end
	
	def current_user=(user)
		#@@current_user=user
		cookies[:current_user] = user
	end
	
	def set_user(user)
		#Client.where(first_name: 'Lifo')
		Rails.logger.debug "Setting user to: " + user
		#@@current_user = user
		cookies[:current_user] = user
	end
	
	def get_user(id)
		 user = Users.find_by(:user => id)
		 
		 user
	end
	
	def clear_user()
		#@@current_user = ""
		cookies.delete :current_user
	end
	
	def requestHTTPS(uri, args)
		#uri = URI.parse("https://foursquare.com/oauth2/access_token")
		uri = URI.parse(uri)
		uri.query = URI.encode_www_form(args)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		response.body
	end
	
	def requestCheckins()
		#https://api.foursquare.com/v2/users/self/checkins?oauth_token=ACCESS_TOKEN
		token = Users.find_by(:user => params[:id])
		args = {oauth_token: token.access_token, v: "20140131"}
		request = requestHTTPS("https://api.foursquare.com/v2/users/self/checkins",args)
		checkins = JSON.parse(request)["response"]["checkins"]
		items = checkins["items"]
		
		#JSON.parse(checkins["items"])
		items
	end
	
	def requestUserlessCheckin()
		#this gets like... EVERYTHING
		#https://api.foursquare.com/v2/venues/search?ll=40.7,-74&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&v=YYYYMMDD
		client_id = "QM50Z5KIPPBQAQ3CAB1POYS5K5P2SBIRQZBTJBGCHI0LLF4E"
        client_secret = "BI4LKYTMWVUK1WKAX3HBKJQBZRVBNVJA1HMG10IR10EJ5SVQ"
		
		args = {client_id: client_id, client_secret: client_secret, ll: '40.7,-74', v: "20140131"}
		request = requestHTTPS("https://api.foursquare.com/v2/venues/search",args)
		Rails.logger.debug "Request:\n" + JSON.pretty_generate(JSON.parse(request))
		checkins = JSON.parse(request)["response"]["checkins"]
		items = checkins["items"]
		items
	end
	
	def getCheckIns()
		array = requestCheckins()
		#requestCheckins()
		#requestUserlessCheckin()
		if current_user() == nil or current_user() != params[:id]
			array = array[0,1]
		end
		
		if array == nil
			return []
		end
		
		array
	end
end
