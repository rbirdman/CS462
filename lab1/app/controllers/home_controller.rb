class HomeController < ApplicationController
	include SslRequirement
	
	#ssl_required :signup, :payment
    #ssl_allowed :index
    #https://github.com/rails/ssl_requirement
	
	ssl_required :home
	ssl_allowed :index
	
    before_filter :initialize
    
    def initialize
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
				
				Rails.logger.debug "Home url: " + @home_url
                redirect_to @fourSquare.authorize_url(@home_url + "/token/" + id)
				
				#temp = Users.create(:user => id, :access_token => "12345")
				#temp.save
			end
			
			
		else
			
		end
    end
	
	def get_token
		id = params[:id]
        
        if params[:code]
        
            Rails.logger.debug "Getting token"
            Rails.logger.debug "Id: " + id
        
            access_token = @fourSquare.access_token(params[:code], @home_url + "/token/"+id)
            #Do I have THE token at this point?
            Rails.logger.debug "First: " + access_token
        else
            Rails.logger.debug "Access Token: " + params[:access_token]
        end
	end
	
	def get_access_token
        id = params[:id]
        Rails.logger.debug "Getting access token for: " + id
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
            
            redirect_to "/profile/" + id
            return
        else
            #check if called from SquareTag, get data
            
            #Users.create(:user => id, :access_token => "12345")
            
        end
        
        Rails.logger.debug "Unauthorized"
        redirect_to "/login"
	end
	
end
