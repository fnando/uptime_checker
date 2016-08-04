module UptimeChecker
  class Checker
    def self.start(options, store)
      Thread.new do
        new(options, store).check
      end
    end

    attr_reader :options, :store

    def key
      @key ||= "uptime_checker:#{SCHEMA}:#{Digest::MD5.hexdigest(url)}"
    end

    def initialize(options, store)
      @options = options
      @store = store
    end

    def url
      options[:url]
    end

    def expected_body
      options[:body]
    end

    def expected_status
      options[:status]
    end

    def min_failures
      options[:min_failures] || 1
    end

    def check
      UptimeChecker.log message: "check started",
                        url: url

      current_state = retrieve_current_state
      previous_state = retrieve_previous_state
      transition = Transition.new(previous_state, current_state)

      store.set(key, transition.state)
      log_status(transition)
      notify(transition)
    end

    def retrieve_previous_state
      payload = if store.exist?(key)
                  store.get(key)
                else
                  {passed: true, time: current_timestamp}
                end

      State.new(payload)
    end

    def retrieve_current_state
      response = HttpClient.get(url)
      State.new(passed: passed?(response), time: current_timestamp)
    rescue Errno::ECONNREFUSED, Aitch::RequestTimeoutError
      State.new(passed: false, time: current_timestamp)
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

      #site is offline for 5 minutes
      Notifier.warning(options, transition) if notify_down_warning?(transition)
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

    def notify_down_warning?(transition)
      time_down = transition.current.time - transition.previous.time
      time_down == 5.minutes &&
        !transition.previous.passed &&
        !transition.current.passed
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
