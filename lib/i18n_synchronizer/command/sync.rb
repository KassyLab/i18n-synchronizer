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

        case @configuration.format
        when "ios"
          sync_ios
        when "android"
          sync_android
        when "xliff", "xlf"
          sync_xliff
        end
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

      def sync_android
        raise InformativeError, "Synchronizing with Android format is not yet implemented"
      end

      def filter_pull_files
        files = Dir.entries(@dir + "/l10n-yaml")
                        .select { |entry| entry.end_with? ".l10n.yml" }
                        .map { |entry| entry[..-10] }
        pull_file_included = @configuration.pull.includes
                                 .select { |include| include.type == "files" }
                                 .map { |include| include.value }
        pull_file_excluded = @configuration.pull.excludes
                                 .select { |exclude| exclude.type == "files" }
                                 .map { |exclude| exclude.value }
        files.select! { |file| pull_file_included.include? file } unless pull_file_included.empty?
        files.rejet! { |file| pull_file_excluded.include? file } unless pull_file_excluded.empty?

        files
      end

      def sync_ios
        files = filter_pull_files

        pull_tags_included = @configuration.pull.includes
                                 .select { |include| include.type == "tags" }
                                 .map { |include| include.value }
        pull_tags_excluded = @configuration.pull.excludes
                                 .select { |exclude| exclude.type == "tags" }
                                 .map { |exclude| exclude.value }

        localizations = Hash.new
        files.each do |file|
          file_l10n = YAML.load_file("#{@dir}/l10n-yaml/#{file}.l10n.yml")
          file_l10n.select! { |_, l10n| (pull_tags_included & l10n["tags"]).count == 1 } unless pull_tags_included.empty?
          file_l10n.rejet! { |_, l10n| (pull_tags_excluded & l10n["tags"]).count == 1 } unless pull_tags_excluded.empty?
          duplicated_keys = localizations.keys & file_l10n.keys
          localizations.merge! file_l10n
        end

        puts localizations.map { |key, l10n| "\"#{key}\" = \"#{l10n['locales']['fr']}\";" }
      end

      def sync_xliff
        raise InformativeError, "Synchronizing with XLIFF format is not yet implemented"
      end
    end
  end
end