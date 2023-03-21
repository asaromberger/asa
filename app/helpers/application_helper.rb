module ApplicationHelper

    def sign_in(user)
        remember_token = User.new_remember_token
        cookies[:remember_token] = { :value => remember_token }
        user.update_attribute(:remember_token, User.encrypt(remember_token))
        self.current_user = user
    end

    def current_user
        remember_token = User.encrypt(cookies[:remember_token])
        @current_user ||= User.find_by(remember_token: remember_token)
    end

    def current_user?(user)
        current_user == user
    end

    def signed_in?
        !current_user.nil?
    end

    def sign_out
	if current_user
		current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
	end
        cookies.delete(:remember_token)
        self.current_user = nil
    end

    def current_user=(user) # used by sign_out to set @current_user = nil
        @current_user = user
    end

    def require_signed_in
        unless signed_in?
            redirect_to root_path, notice: "Please sign in"
        end
    end

	def to_email(string)
		return(string.gsub(/^\s*/, '').gsub(/\s*$/, '').downcase)
	end

	def current_user_role(role)
		return Permission.where("user_id = ? AND pkey = ?", current_user.id, role).count > 0
	end

	def percent_fmt(value)
		return(((value * 10).to_i.to_f / 10).to_s + '%')
	end

end
