require 'yaml'

module I18nSynchronizer
  module Helper
    class PullHelper
      # @param configuration [Configuration]
      # @param repo_dir [String]
      def self.run(configuration, repo_dir)
        local_files_basename = local_files(configuration).map { |file| file.match(local_file_regex)[4] }.uniq

        local_files_basename.each do |local_file_basename|
          strings_file = I18nSynchronizer::File::StringsFile.new
          strings_file.name = local_file_basename

          configuration.pull.select { |pull_request| pull_request.into == local_file_basename }
              .each do |pull_request|
            strings_file.sections << build_section(repo_dir, pull_request)
          end

          local_files = Dir["**/*.lproj/#{local_file_basename}.strings"] & local_files(configuration)
          local_files.each do |local_file|
            locale = local_file.match(local_file_regex)[1]
            strings_file.locale = locale
            ::File.write(local_file, strings_file.serialized)
          end
        end
      end

      # @param repo_dir [String]
      # @param pull_request [PullRequest]
      # @return [Section]
      def self.build_section(repo_dir, pull_request)
        path = "#{repo_dir}/l10n-yaml/#{pull_request.file}.l10n.yml"

        file_l10n = YAML.load_file(path)
        file_l10n.select! { |_, l10n| (pull_request.tags - l10n["tags"]).empty? } unless pull_request.tags.empty?

        file_l10n = Hash[file_l10n.map {|key,l10n| [key, l10n["locales"]]}]

        section = I18nSynchronizer::File::Section.new
        section.name = pull_request.file
        section.localizations = file_l10n
        section
      end

      # @param repo_dir [String]
      # @param file [String]
      # @param pull [PullRequest]
      # @return [Section]
      def self.section_for_file(repo_dir, file, pull)
        path = "#{repo_dir}/l10n-yaml/#{file}.l10n.yml"

        pull_tags_included = pull.includes
                                 .select { |include| include.file == file }
                                 .map { |include| include.tags }.flatten
        pull_tags_excluded = pull.excludes
                                 .select { |exclude| exclude.file == file }
                                 .map { |exclude| exclude.tags }.flatten

        file_l10n = YAML.load_file(path)
        file_l10n.select! { |_, l10n| (pull_tags_included & l10n["tags"]).count >= 1 } unless pull_tags_included.empty?
        file_l10n.rejet! { |_, l10n| (pull_tags_excluded & l10n["tags"]).count >= 1 } unless pull_tags_excluded.empty?

        file_l10n = Hash[file_l10n.map {|key,l10n| [key, l10n["locales"]]}]

        section = I18nSynchronizer::File::Section.new
        section.name = file
        section.localizations = file_l10n
        section
      end

      # @param pull [PullConfiguration]
      # @param files [Array<String>]
      # @return [Array<String>]
      def self.filter_pull_files(pull, files)
        pull_file_included = pull.includes
                                 .map { |include| include.file }
        pull_file_excluded = pull.excludes
                                 .select { |exclude| exclude.type == "files" }
                                 .map { |exclude| exclude.value }
        files.select! { |file| pull_file_included.include? file } unless pull_file_included.empty?
        files.rejet! { |file| pull_file_excluded.include? file } unless pull_file_excluded.empty?

        files
      end

      # @param configuration [Configuration]
      # @return [Array<String>]
      def self.local_files(configuration)
        regex = Regexp.new("^#{configuration.include.map { |include| Regexp.quote include }.join '|'}")
        files = Dir["**/*.lproj/*.strings"]
        files.select! { |lproj| regex =~ lproj }
        files
      end

      # @return [Array<String>]
      def self.repo_files(repo_dir)
        Dir.entries(repo_dir + "/l10n-yaml")
            .select { |entry| entry.end_with? ".l10n.yml" }
            .map { |entry| entry[..-10] }
            .sort
      end

      # @return Regexp
      def self.local_file_regex
        /.*\/(([a-zA-Z]{2}(-[a-zA-Z]{2})?)*)\.lproj\/(.*)\.strings/
      end
    end
  end
end
