require "bundler/setup"
require "noti"

$stdout << "What's your Noti application token? "
app_token = gets.chomp

Noti.app = app_token
token = Noti::Token.create_request_token("https://notiapp.com/apps/authorised")

puts "To authorize Uptime Checker, visit #{token.redirect_url}"
puts "Press ENTER you're done."
gets

access_token = Noti::Token.get_access_token(token.request_token)

puts "Your user token is: #{access_token}"
