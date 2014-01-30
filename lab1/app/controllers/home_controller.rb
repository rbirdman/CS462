class HomeController < ApplicationController
	include SslRequirement
	
	#ssl_required :signup, :payment
    #ssl_allowed :index
    #https://github.com/rails/ssl_requirement
	
	ssl_required :home
	ssl_allowed :index
	
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
			
			
		else
			
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
	
	
	
end
