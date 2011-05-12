require 'acts_as_label'

if defined?(ActiveRecord)
  Coroutine::ActsAsLabel::install
end