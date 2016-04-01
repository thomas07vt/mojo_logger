require 'pry'
require 'benchmark'
require 'mojo_logger'

MojoLogger.config do |c|
  c.default_log_level= :info
  c.log_file = '/dev/null'
end

@mojo_args = [{}, "Category", "Test Message", { key: "This is a string", key2: "this is some other thing", 'key2' => "Third thing" }]

5.times do

  Benchmark.bmbm do |x|
    x.report("debug")  { 100000.times { MojoLogger.debug "Log message" }  }
    x.report("info")   { 100000.times { MojoLogger.info "Log message"  }  }
  end


  Benchmark.bmbm do |x|
    x.report("mojo_debug")  { 100000.times { MojoLogger.mojo_debug(*@mojo_args) }  }
    x.report("mojo_info")   { 100000.times { MojoLogger.mojo_info(*@mojo_args)  }  }
  end

end


