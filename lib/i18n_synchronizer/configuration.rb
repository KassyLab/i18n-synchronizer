require 'yaml'

module I18nSynchronizer
  class Configuration
    attr_accessor :repository, :format, :include, :push

    # @return [Array<PullRequest>]
    attr_accessor :pull

    def self.initialize_from_file
      config = new

      yml = YAML.load_file('.l10n.yml')
      config.repository = yml['repository']
      config.format = yml['format']
      config.include = yml['include']
      yml_pull = yml['pull']
      if yml_pull.kind_of?(Array)
        config.pull = yml_pull.map { |pull| build_pull_request pull }
      else
        config.pull = [build_pull_request(yml_pull)]
      end
      #config.push = PushConfiguration.new yml['push']

      config
    end

    # @param dictionary [Hash]
    # @return [PullRequest]
    def self.build_pull_request(dictionary)
      tags = dictionary["tags"]
      unless tags.kind_of?(Array)
        tags = [tags]
      end

      PullRequest.new(dictionary["file"], tags, dictionary["into"])
    end

    class PullRequest
      # @return [String]
      attr_accessor :file

      # @return [Array<String>]
      attr_accessor :tags

      # @return [String]
      attr_accessor :into

      def initialize(file, tags, into)
        @file = file
        @tags = tags
        @into = into
      end
    end

    class PushRequest
      def initialize()

      end
    end
  end
end