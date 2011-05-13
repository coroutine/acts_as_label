# acts_as_label extension
require File.dirname(__FILE__) + "/acts_as_label/base"


# add extensions to active record
begin
  ::ActiveRecord::Base.send(:include, Coroutine::ActsAsLabel::Base)
rescue
  # do nothing
end