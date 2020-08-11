# frozen_string_literal: true

module I18nSynchronizer

  # Indicates a runtime error **not** caused by a bug.
  #
  class PlainInformativeError < ::StandardError; end

  # Indicates a user error.
  #
  class InformativeError < PlainInformativeError; end

end

require 'i18n_synchronizer/version'
require 'i18n_synchronizer/executable'
require 'i18n_synchronizer/configuration'
require 'i18n_synchronizer/command'