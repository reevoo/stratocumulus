# encoding: UTF-8


module Stratocumulus
  class Database
    # #rewind is undefined so fog won't try to call rewind on a pipe
    class PipeIO < IO
      undef rewind
    end
  end
end
