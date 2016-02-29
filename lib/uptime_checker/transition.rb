module UptimeChecker
  class Transition
    attr_reader :previous, :current

    def initialize(previous, current)
      @previous = previous
      @current = current
    end

    def failures
      if current.passed
        0
      else
        previous.failures + 1
      end
    end

    def changed?
      previous.passed != current.passed
    end

    def from_up?
      previous.passed && !current.passed
    end

    def from
      status(previous.passed)
    end

    def to
      status(current.passed)
    end

    def state
      {
        "failures" => failures,
        "time" => time,
        "passed" => current.passed
      }
    end

    def time
      changed? && from_up? ? current.time : previous.time
    end

    private

    def status(passed)
      passed ? "up" : "down"
    end
  end
end
