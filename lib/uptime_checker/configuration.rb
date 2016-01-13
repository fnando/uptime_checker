module UptimeChecker
  Config = Env::Vars.new do
    optional :config_file, string, File.join(Dir.pwd, "checkers.yml")
    optional :abort_thread_on_exception, bool, false
    optional :interval, int, 30
    optional :locale, string, "en"

    optional :twitter_consumer_key, string, nil
    optional :twitter_consumer_secret, string, nil
    optional :twitter_access_token, string, nil
    optional :twitter_access_secret, string, nil

    optional :telegram_api_token, string, nil

    optional :sendgrid_username, string, nil
    optional :sendgrid_password, string, nil

    optional :hipchat_api_token, string, nil
    optional :noti_api_token, string, nil

    optional :slack_api_token, string, nil
    optional :pushover_application_token, string, nil

    optional :campfire_api_token, string, nil
    optional :campfire_subdomain, string, nil

    property :redis, -> { Redis.new }
  end
end
