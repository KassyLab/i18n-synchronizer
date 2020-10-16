require 'tmpdir'
require 'yaml'

module I18nSynchronizer
  class Command
    class Sync < Command
      self.summary = 'Synchronize locales and remotes localizations'

      self.description = <<-DESC
        Push new localizations from the local project to the repository 
        and pull localizations from the repository to the local project.
      DESC

      self.arguments = [
          CLAide::Argument.new('REPOSITORY', false),
          CLAide::Argument.new('FORMAT', false),
      ]

      def initialize(argv)
        @configuration = Configuration.initialize_from_file
        @configuration.repository = argv.shift_argument || @configuration.repository
        @configuration.format = argv.shift_argument || @configuration.format
        super
      end

      def validate!
        super
        unless @configuration.repository && @configuration.format
          help! 'Synchronizing localizations needs a `REPOSITORY` and a `FORMAT`'
        end
        allowed_formats = ["ios", "android", "xliff", "xlf"]
        unless allowed_formats.include? @configuration.format
          help! "`FORMAT` needs to be one of the following type: [#{allowed_formats.join ","}]"
        end
      end

      def run
        create_repos_dir
        clone_repo
        #checkout_branch

        I18nSynchronizer::Helper::PullHelper.run(@configuration, @dir)
      end

      private

      # Creates temporary repos directory.
      #
      # @return [void]
      #
      # @raise  If the directory cannot be created due to a system error.
      #
      def create_repos_dir
        @dir = Dir.mktmpdir("i18n-sync-")
      rescue => e
        raise InformativeError, "Could not create temporary directory for cloning repository."
      end

      # Clones the git localization repository.
      #
      # @return [void]
      #
      def clone_repo
          Dir.chdir(@dir) do
            command = ['clone', @configuration.repository, '.']
            git!(command)
          end
      end

      # Checks out the branch of the git spec-repo if provided.
      #
      # @return [void]
      #
      def checkout_branch
        Dir.chdir(@dir) { git!('checkout', @configuration.branch) } if @configuration.branch
      end
    end
  end
end