require 'yaml'

module I18nSynchronizer
  class Configuration
    attr_accessor :repository, :format, :include, :pull, :push

    def self.initialize_from_file
      config = new

      yml = YAML.load_file('.l10n.yml')
      config.repository = yml['repository']
      config.format = yml['format']
      config.include = yml['include']
      if yml['pull'].kind_of?(Array)
        config.pull = yml['pull'].map { |pull| PullConfiguration.new pull }
      else
        pull = PullConfiguration.new yml['pull']
        config.pull = [pull]
      end
      config.push = PushConfiguration.new yml['push']

      config
    end

    class PullCondition
      # @return [String]
      attr_accessor :file

      # @return [Array<String>]
      attr_accessor :tags

      def initialize(file, tags)
        @file = file
        @tags = tags
      end
    end

    class PullConfiguration
      # @return [String]
      attr_accessor :into

      # @return [Array<PullCondition>]
      attr_accessor :includes

      # @return [Array<PullCondition>]
      attr_accessor :excludes

      def initialize(dictionary)
        @into = dictionary['into']
        @includes = []
        @excludes = []

        @includes = build_conditions(dictionary['include']) if dictionary['include']
        @excludes = build_conditions(dictionary['exclude']) if dictionary['exclude']
      end

      # @return [Array<PullCondition>]
      def build_conditions(conditions)
        pull_conditions = Array.new
        conditions.each do |condition|
          pull_conditions << PullCondition.new(condition['file'], condition['tags'])
        end
        pull_conditions
      end
    end

    class PushConfiguration
      def initialize(dictionary)

      end
    end
  end
end