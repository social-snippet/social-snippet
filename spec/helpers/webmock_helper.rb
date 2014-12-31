require "webmock"

RSpec.configure do |config|
  config.before do
    WebMock.disable_net_connect!(
      :allow => [
        "codecov.io"
      ]
    )
  end

  config.after do
    WebMock.reset!
  end
end

