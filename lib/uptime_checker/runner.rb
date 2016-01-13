module UptimeChecker
  def self.run(config: load_file(Config.config_file))
    Runner.new(config).run
  end

  def self.load_file(path)
    YAML.load ERB.new(File.read(path), nil, "-").result(binding)
  end

  class Runner
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def run
      loop do
        spawn_checkers
        sleep Config.interval
      end
    end

    def spawn_checkers
      config["checkers"].each do |site|
        Checker.start(site)
      end
    end
  end
end
