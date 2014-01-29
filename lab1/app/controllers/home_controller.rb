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
	end
	
    def signup
		# Non-SSL access will be redirected to SSL
    end
    
    def payment
		# Non-SSL access will be redirected to SSL
    end
	
    def index
		# This action will work either with or without SSL
    end
	
    def other
		# SSL access will be redirected to non-SSL
    end
end
