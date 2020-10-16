module I18nSynchronizer
  class File
    class << self
      # @return [String] file extension
      attr_accessor :extension
    end

    # @return [String] file name
    attr_accessor :name

    # @return [String]
    attr_accessor :locale

    # @return [Array<Section>]
    attr_accessor :sections

    def initialize
      super
      @sections = []
    end

    # @attr name [String]
    # @attr localizations [Hash<String,String>]
    class Section
      attr_accessor :name, :localizations

      # @return [String]
      def serialized
        ""
      end

      def header
        "/********** #{@name} **********/\n"
      end

      def footer
        ""
      end
    end

    #-----------------------------------------------------------------------#

    require 'i18n_synchronizer/file/strings_file'

  end
end