require "webmock"

RSpec.configure do |config|
  config.before do
    WebMock.disable_net_connect!(
      :allow => [
        "codeclimate.com"
      ]
    )
  end

  config.after do
    WebMock.reset!
  end
end

