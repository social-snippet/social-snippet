# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :shell do
  watch(/(.*)\.rb/) do |m|
    system "bundle exec rake spec"
    system "bundle exec rake test"
  end
end
