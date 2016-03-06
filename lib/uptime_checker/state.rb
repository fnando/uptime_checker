module UptimeChecker
  class State
    attr_reader :passed, :time, :failures

    def initialize(payload)
      @passed = payload[:passed]
      @time = Time.parse(payload[:time])
      @failures = payload[:failures] || 0
    end

    def as_json(*)
      {passed: passed, time: time, failures: failures}
    end
  end
end
