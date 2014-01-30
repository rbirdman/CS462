module HomeHelper
	$current_user = nil

	def current_user
		current_user = $current_user
	end
	
	def set_user(user)
		$current_user = user
	end
	
	def clear_user()
		$current_user = nil
	end
end
