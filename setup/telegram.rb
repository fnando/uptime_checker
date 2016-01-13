require "bundler/setup"
require "aitch"

$stdout << "What's your Telegram bot token? "
bot_token = gets.chomp

response = Aitch.get("https://api.telegram.org/bot#{bot_token}/getUpdates")
payload = response
          .data["result"]
          .sort_by {|result| result["update_id"] }
          .last

if payload
  channel_id = payload.dig("message", "chat", "id")
  puts "The channel id is #{channel_id}"
else
  puts "No messages found."
  exit 1
end
