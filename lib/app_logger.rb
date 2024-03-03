# frozen_string_literal: true

require 'logger'

module AppLogger
  def self.logger
    @logger ||= Logger.new($stdout).tap do |log|
      log.progname = 'GithubExplorer'
      log.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime}: #{severity} [#{progname}]: #{msg}\n"
      end
    end
  end
end
