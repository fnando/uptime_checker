module UptimeChecker
  class Checker
    def self.start(options)
      Thread.new do
        new(options).check
      end
    end

    attr_reader :options

    def key
      @key ||= "uptime_checker:#{Digest::MD5.hexdigest(url)}"
    end

    def initialize(options)
      @options = options
    end

    def url
      @options["url"]
    end

    def expected_body
      @options["body"]
    end

    def expected_status
      @options["status"]
    end

    def check
      UptimeChecker.log action: "checking",
                        url: url

      previous_state = retrieve_previous_state
      current_state = retrieve_current_state

      Config.redis.set(key, current_state)
      notify(previous_state, current_state)
    end

    def retrieve_previous_state
      if Config.redis.exists(key)
        Config.redis.get(key) == "true"
      else
        true
      end
    end

    def retrieve_current_state
      response = HttpClient.get(url)
      passed?(response)
    rescue Errno::ECONNREFUSED, Aitch::RequestTimeoutError
      false
    end

    def passed?(response)
      [
        body_match?(response.body),
        status_match?(response.code)
      ].all?
    end

    def body_match?(body)
      return true unless expected_body
      body && body.include?(expected_body)
    end

    def status_match?(status)
      return true unless expected_status
      status && [expected_status].flatten.compact.include?(status)
    end

    def status(target)
      target ? "up" : "down"
    end

    def notify(from, to)
      # site was online, and still is.
      return if from && to

      # site as offline, and still is.
      return if !from && !to

      log_transition(from, to)

      # site was online, and now is offline.
      return Notifier.down(options) if from && !to

      # site was offline, and now is online.
      Notifier.up(options)
    end

    def log_transition(from, to)
      UptimeChecker.log check: url,
                        from: status(from),
                        to: status(to)
    end
  end
end
