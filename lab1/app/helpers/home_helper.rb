module HomeHelper
	#$current_user = nil
	
	@@current_user = ""
	def current_user
		@@current_user
	end
	
	def current_user=(user)
		@@current_user=user
	end
	
	def set_user(user)
		#Client.where(first_name: 'Lifo')
		Rails.logger.debug "Setting user to: " + user
		@@current_user = user
	end
	
	def get_user(id)
		 user = Users.find_by(:user => id)
		 
		 user
	end
	
	def clear_user()
		@@current_user = ""
	end
	end
end
