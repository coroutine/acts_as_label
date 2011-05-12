# acts_as_label extension
require File.dirname(__FILE__) + "/acts_as_label/base"

module Coroutine
  module ActsAsLabel
    def self.install
      # add extensions to active record
      ::ActiveRecord::Base.send(:include, Coroutine::ActsAsLabel::Base)
    end
  end
end
