class HomeController < ApplicationController
	include SslRequirement
	
	#ssl_required :signup, :payment
    #ssl_allowed :index
    #https://github.com/rails/ssl_requirement
	
	ssl_required :home
	ssl_allowed :index
	
	require "net/http"
	require "json"
	
	#caused problems with rendering
    #before_filter :initialize
    
    def set_variables
    	@client_id = "QM50Z5KIPPBQAQ3CAB1POYS5K5P2SBIRQZBTJBGCHI0LLF4E"
        @client_secret = "BI4LKYTMWVUK1WKAX3HBKJQBZRVBNVJA1HMG10IR10EJ5SVQ"
        @home_url = "https://ec2-54-221-60-170.compute-1.amazonaws.com"    
        @fourSquare = Foursquare::Merchant::Consumer.new(@client_id, @client_secret)
    end
	
	def home
		
	end
	
	def index
		puts "<html>Received SSL connection</html>"
		Rails.logger.debug "Opening Index"
	end
	
    def signup
		Rails.logger.debug "Opening Signup"
    end
    
    def login
		Rails.logger.debug "Opening Login"
		
		set_variables()
		
		id = params[:id]
		if id
			#Users.create(:user => id, :access_token => "433LBRENTEZLBGW4UZE4XAPWXNV51D5FQDJAHM0HRQXSWHMC")
			user = Users.find_by user: id
			if user
			#if Users.exists?(id)
				Rails.logger.debug "Setting user: " + user.user
				Rails.logger.debug "User token: " + user.access_token
				#reroute
				redirect_to "/authorize/" + id
			else
				Rails.logger.debug "Unknown login User"
				#authorize
				
				redirect_url = @home_url + "/token/" + id
				Rails.logger.debug "Home url: " + redirect_url
                #redirect_to @fourSquare.authorize_url(@home_url + "/token/" + id)
				redirect_to "https://foursquare.com/oauth2/authenticate?client_id=#{@client_id}&response_type=code&redirect_uri=#{redirect_url}"
				
				#temp = Users.create(:user => id, :access_token => "12345")
				#temp.save
			end
			
			
		else
			
		end
    end
	
	def get_token
		id = params[:id]
        set_variables()
        
        if params[:code]
        
            Rails.logger.debug "Getting token"
            Rails.logger.debug "Id: " + id
        
            #access_token = @fourSquare.access_token(params[:code], @home_url + "/token/"+id)
            
            uri = URI.parse("https://foursquare.com/oauth2/access_token")
			access_url = @home_url + "/token/"+id
			args = {client_id: @client_id, client_secret: @client_secret, grant_type: 'authorization_code', redirect_uri: access_url, code: params[:code]}
			uri.query = URI.encode_www_form(args)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
            request = Net::HTTP::Get.new(uri.request_uri)

			response = http.request(request)
			access_token = response.body #this is JSON format
            #Do I have THE token at this point?
            Rails.logger.debug "First: " + access_token
            access_token = JSON.parse(access_token)
            Rails.logger.debug "Second: " + access_token["access_token"]
		Users.create(:user => id, :access_token => access_token["access_token"]);
		redirect_to "/authorize/" + id
		
        else
		Rails.logger.debug "No id"
            redirect_to "/login"
        end
	end
	
    def profile
		Rails.logger.debug "Opening Profile"
		id = params[:id]
		if id
			Rails.logger.debug "Profile: " + id
			
		else
			Rails.logger.debug "Profile: Should view table"
		end
    end
	
	#authorizes from self and from SquareTag
	def authorize
		id = params[:id]
		
        Rails.logger.debug "Authorizing: " + id
        user = Users.find_by user: id
        #if Users.exists?(id)
        if user
            Rails.logger.debug "User accepted"
            #set current_user
            
            redirect_to "/profile/" + id
            return
        else
            #check if called from SquareTag, get data
            
            #Users.create(:user => id, :access_token => "12345")
            
        end
        
        Rails.logger.debug "Unauthorized"
        redirect_to "/login"
	end
	
	def logout
		Rails.logger.debug "Logging out"
		view_context.clear_user()
		val = view_context.current_user
		if val != "" or val != nil
			Rails.logger.error "Logout failure: still logged as " + val
		else
			Rails.logger.debug "Logout successful"
		end
		
		redirect_to :back
	end
end
