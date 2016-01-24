require 'jumpstart_auth'
require 'bitly'

class MicroBlogger

  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length > 140
      puts "The message is too long."
    else
      @client.update(message)
    end
  end


  def run
    puts "Welcome to the JSL Twitter Client!"
    input = ""
    while input != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when "q" then puts "Goodbye!"
      when "t" then tweet(parts[1..-1].join(" "))
      when "dm" then dm(parts[1], parts[2..-1].join(" "))
      when "spam" then spam_my_followers(parts[1..-1].join(" "))
      when "elt" then everyones_last_tweet()
      when "s" then shorten(parts[1])
      when "turl" then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      else
        puts "Sorry I don't know how to #{command}"
      end
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      message = "d #@#{target} #{message}"
      tweet(message)
    else
      puts "Can only DM followers"
    end
  end

  def followers_list
    screen_names = []
    screen_names << @client.user(follower).screen_name
    return screen_names
  end

  def spam_my_followers(message)
    followers = followers_list()
    followers.each do |follower|
      dm(follower, message)
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(original_url).short_url
  end


  def everyones_last_tweet
    friends = @client.friends
    friends.sort_by { |friend| friend.screen_name.downcase}
    friends.each do |friend|
      timestamp = friend.status.created_at
      last_tweet = friend.status.text
      print friend.screen_name + " " + "said... "
      print last_tweet + " at "
      print timestamp.strftime("%A, %b, %d")
      puts ""
    end
  end

end


blogger = MicroBlogger.new
blogger.run

#5046427
