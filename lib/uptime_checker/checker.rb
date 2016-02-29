module UptimeChecker
  class Checker
    def self.start(options)
      Thread.new do
        new(options).check
      end
    end

    attr_reader :options

    def key
      @key ||= "uptime_checker:#{SCHEMA}:#{Digest::MD5.hexdigest(url)}"
    end

    def initialize(options)
      @options = options
    end

    def url
      options["url"]
    end

    def expected_body
      options["body"]
    end

    def expected_status
      options["status"]
    end

    def min_failures
      options["min_failures"] || 1
    end

    def check
      UptimeChecker.log message: "check started",
                        url: url

      previous_state = retrieve_previous_state
      current_state = retrieve_current_state
      transition = Transition.new(previous_state, current_state)

      Config.redis.set(key, transition.state.to_json)
      log_status(transition)
      notify(transition)
    end

    def retrieve_previous_state
      payload = if Config.redis.exists(key)
                  JSON.load(Config.redis.get(key))
                else
                  {"passed" => true, "time" => current_timestamp}
                end

      State.new(payload)
    end

    def retrieve_current_state
      response = HttpClient.get(url)
      State.new("passed" => passed?(response), "time" => current_timestamp)
    rescue Errno::ECONNREFUSED, Aitch::RequestTimeoutError
      State.new("passed" => false, "time" => current_timestamp)
    end

    def current_timestamp
      Time.current.iso8601
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

    def notify(transition)
      # site was offline, and now is online.
      Notifier.up(options, transition) if notify_up_change?(transition)

      # site is offline.
      Notifier.down(options, transition) if notify_down_change?(transition)
    end

    def notify_up_change?(transition)
      transition.changed? &&
        !transition.previous.passed &&
        transition.previous.failures >= min_failures
    end

    def notify_down_change?(transition)
      !transition.current.passed &&
        transition.failures == min_failures
    end

    def log_status(transition)
      options = {url: url, message: "check finished"}

      if transition.changed?
        options = options.merge(
          from: transition.from,
          to: transition.to,
          state: "changed"
        )
      else
        options[:state] = "unchanged"
      end

      UptimeChecker.log(options)
    end
  end
end
