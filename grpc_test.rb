# require "grpc"
require "rspec"
require "tempfile"
RSpec::Core::Runner::run(['spec'], Tempfile.new, Tempfile.new)
