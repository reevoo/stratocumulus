# encoding: UTF-8

# Rewind is undefined so fog won't try to call rewind on a pipe
# This should be a refinement, but we are supporting 1.9.3 (for now)

class IO
  undef rewind
end
