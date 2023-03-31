class User < ApplicationRecord

	before_save { self.email = email.downcase }
	before_create :create_remember_token

	has_secure_password

	has_many :permissions
	has_many :health_data
	has_many :music_playlists

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates(:email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false })

	def generate_token(column)
  		begin
    		self[column] = SecureRandom.urlsafe_base64
  		end while User.exists?(column => self[column])
	end

	def User.new_remember_token
    	SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private

    def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
    end

end
