# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../app")
loader.collapse("#{__dir__}/../app/controllers")
loader.collapse("#{__dir__}/../app/services")
loader.push_dir("#{__dir__}/../lib")

loader.setup
