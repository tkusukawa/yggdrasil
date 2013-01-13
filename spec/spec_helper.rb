require File.dirname(__FILE__) + '/../lib/yggdrasil'

def catch_stdout
  exit 1 unless block_given?
  tmp_out = $stdout
  $stdout = StringIO.new
  yield
  $stdout,tmp_out = tmp_out, $stdout
  tmp_out.string
end

