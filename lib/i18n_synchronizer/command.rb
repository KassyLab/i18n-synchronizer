require 'claide'

module I18nSynchronizer
  class PlainInformativeError
    include CLAide::InformativeError
  end

  class Command < CLAide::Command
    require 'i18n_synchronizer/command/sync'

    self.abstract_command = true
    self.command = 'i18n-synchronizer'
    self.default_subcommand = 'sync'
    self.version = VERSION

    #-----------------------------------------------------------------------#

    extend Executable
    executable :git
  end
end
