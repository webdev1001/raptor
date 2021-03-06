def env(method, path, body="")
  {'REQUEST_METHOD' => method,
   'PATH_INFO' => path,
   'rack.input' => body}
end

def request(method, path, body="")
  Rack::Request.new(env(method, path, body))
end

class InjectorNotAllowed < RuntimeError; end
def disallow_injector_use
  Raptor::Injector.stub(:new).and_raise(InjectorNotAllowed)
end

class RedirectToMatcher
  def initialize(expected_location)
    @expected_location = expected_location
  end
  def matches?(response)
    response.status.should == 302
    response['Location'].should == @expected_location
  end
end

module RSpec::Matchers
  def redirect_to(expected)
    RedirectToMatcher.new(expected)
  end
end

# The first instantiation of these is very slow for some reason. Do it here so
# it doesn't pollute test runtimes.
Rack::Request.new({})
Rack::Response.new

