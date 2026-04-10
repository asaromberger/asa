class UserMailer < ActionMailer::Base
	default from: "asa.romberger@earthlink.net"

	def trace_mail(message)
		@message = message
		@mail_to = Permission.joins(:user).where("pkey = 'trace_mail'").pluck('email')
		mail to: @mail_to, subject: "Wolz-Romberger Web Trace"
	end

	def send_mail(subject, message)
		@message = message
		@mail_to = Permission.joins(:user).where("pkey = 'trace_mail'").pluck('email')
		mail to: @mail_to, subject: subject
	end

end
