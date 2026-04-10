namespace :scheduled_task do

	desc "Trace"
	task :trace_mail, [:subject] => :environment do
		UserMailer.trace_mail(args[:subject]).deliver!
	end

	desc "Mail"
	task :send_mail, [:subject, :body] => :environment do |t, args|
		UserMailer.send_mail(args[:subject], args[:body]).deliver!
	end

end
