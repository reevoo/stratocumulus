# encoding: UTF-8

# Rewind is undefined so fog won't try to call rewind on a pipe

module Stratocumulus
  class Database
    class PipeIO < IO
      undef rewind
    end
  end
end
