require 'jumpstart_auth'
require 'time'

class MicroBlogger
	attr_reader :client

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
			while command != "q"
				printf "enter command:"
				input = gets.chomp
				parts = input.split(' ')
				command = parts[0]
				message = parts[1..-1].join(' ')
			case command
				when 'q' then puts "Goodbye"
				when 't' then tweet(message)
				when 'dm' then dm(parts[1], parts[2..-1].join(' '))
				when 'spam' then spam_my_friend(message)
				when 'elt' then everyones_last_tweet
			else
				puts "Sorry, I don't know how to (#{command})"
			end
		end
	end

	def everyones_last_tweet
		friends = @client.friends
		friends.sort_by!{|follower| follower[:screen_name].downcase}
		puts "#{friends}"
		friends.each do |friends|
			date_created = friends.status[:created_at]
			puts "#{friends[:screen_name]} said this #{date_created.strftime("%A, %b %d")}..."
			puts "#{friends.status[:text]}"
		end
	end

	def follower_list
		screen_names = []
		@client.followers.each{|follower| screen_names << follower[:screen_name]}
		return screen_names
	end

	def spam_my_friend(message)
		screen_names = follower_list
		puts "#{screen_names}"
		screen_names.each{|target| dm(target, message)}
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message:"
		joined_message = "d #{target} #{message}"
		tweet(joined_message)
		
		#Find the list of my followers
		@client.followers
		screen_names = @client.followers.collect{|follower| follower.screen_name}
		
		# #If the target is in this list, send the DM
		if screen_names.include?(target)
			tweet(joined_message)
		else
			puts "You can only DM people that you follow"
		end	
	end

	def tweet(message)
		if message.size <= 140
			@client.update(message)
		else
			puts "Your message is to long"
		end
	end

	def initialize
		puts "Initializing"
		@client = JumpstartAuth.twitter
	end
end

blogger = MicroBlogger.new
blogger.run