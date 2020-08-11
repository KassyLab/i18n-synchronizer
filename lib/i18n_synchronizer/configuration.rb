require 'yaml'

module I18nSynchronizer
  class Configuration
    attr_accessor :repository, :format, :pull, :push

    def self.initialize_from_file
      config = new

      yml = YAML.load_file('.l10n.yml')
      config.repository = yml['repository']
      config.format = yml['format']
      config.pull = PullConfiguration.new yml['pull']
      config.push = PushConfiguration.new yml['push']

      config
    end

    class PullCondition
      attr_accessor :type, :value
    end

    class PullConfiguration
      attr_accessor :includes, :excludes

      def initialize(dictionary)
        @includes = []
        @excludes = []

        dictionary.each do |key, conditions|
          conditions.each do |type, values|
            values.each do |value|
              condition = PullCondition.new
              condition.type = type
              condition.value = value
              if key == "include"
                @includes << condition
              elsif key == "exclude"
                @excludes << condition
              end
            end
          end
        end
      end
    end

    class PushConfiguration
      def initialize(dictionary)

      end
    end
  end
end