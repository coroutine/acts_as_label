module Coroutine                      #:nodoc:
  module ActsAsLabel                  #:nodoc:
    module Base                       #:nodoc: 

      def self.included(base)         #:nodoc:
        base.extend(ClassMethods)
      end

      
      module ClassMethods
      
        
        # == Description
        #
        # This +acts_as+ extension implements a system label and a friendly label on a class and centralizes
        # the logic for performing validations and accessing items by system label.
        #
        #
        # == Usage
        #
        # Simple Example
        #
        #   class BillingFrequency < ActiveRecord::Base
        #     has_many :subscriptions
        #     acts_as_label :default => :monthly
        #   end
        #
        #   class Subscription < ActiveRecord::Base
        #     belongs_to :billing_frequency
        #   end
        #
        #   subscription.billing_frequency = BillingFrequency.monthly
        #   subscription.billing_frequency = BillingFrequency.default
        #
        #
        # STI Example:
        #
        #   class Label < ActiveRecord::Base
        #     acts_as_label :scoped_to => :type
        #   end
        #
        #   class BillingFrequency < Label
        #     has_many :subscriptions
        #     def self.default
        #       BillingFrequency.monthly
        #     end
        #   end
        #
        #   class Subscription < ActiveRecord::Base
        #     belongs_to :billing_frequency
        #   end
        #
        #   subscription.billing_frequency = BillingFrequency.monthly
        #   subscription.billing_frequency = BillingFrequency.default
        #
        #
        # == Configuration
        #
        # * +system_label_cloumn+ - specifies the column name to use for storing the system label (default: +system_label+)
        # * +label_column+ - specifies the column name to use for storing the label (default: +label+)
        # * +default+ - specifies the system label value of the default instance (default: the first record in the default scope)
        # 
        def acts_as_label(options = {})
          
          #-------------------------------------------
          # scrub options
          #-------------------------------------------
          options       = {} unless options.is_a?(Hash)
          system_label  = options.key?(:system_label_column)  ? options[:system_label_column].to_sym  : :system_label
          label         = options.key?(:label_column)         ? options[:label_column].to_sym         : :label
          scope         = options.key?(:scope)                ? options[:scope]                       : "1 = 1"
          default       = options.key?(:default)              ? options[:default].to_sym              : nil
                    
          
          #--------------------------------------------
          # mix methods into class definition
          #--------------------------------------------
          class_eval do
            
            # inheritable accessors
            class_attribute :acts_as_label_system_label_column
            class_attribute :acts_as_label_label_column
            class_attribute :acts_as_label_scope
            class_attribute :acts_as_label_default_system_label

            self.acts_as_label_system_label_column  = system_label
            self.acts_as_label_label_column         = label
            self.acts_as_label_scope                = scope
            self.acts_as_label_default_system_label = default

            # protect attributes
            attr_readonly               system_label
            
            # validations
            validates_presence_of       system_label
            validates_length_of         system_label,  :maximum   => 255
            validates_format_of         system_label,  :with      => /^[A-Z][_A-Z0-9]*$/
            validates_presence_of       label
            validates_length_of         label,         :maximum => 255
            
            # This method catches all undefined method calls. It first sees if any ancestor
            # understands the request. If not, it tries to match the method call to an
            # existing system label. If that is found, it lazily manufacturers a method on the
            # class of the same name. Otherwise, it throws the NoMethodError.
            #
            def self.method_missing(method, *args, &block)
              begin
                super
              rescue NoMethodError => e
                if has_acts_as_label_method?(method)
                  self.__send__(method)
                else
                  raise e
                end
              end
            end
            
                        
            # This method determines whether or not the class has an instance with
            # the given system label. If it does, it also lazily creates a method 
            # that can be accessed without all this method missing nonsense.
            #
            def self.has_acts_as_label_method?(method_name)
              mn = method_name.to_s.underscore
              sl = mn.upcase
              
              if record = by_acts_as_label_system_label(sl)
                eval %Q{
                  class << self
                    def #{mn}
                      by_acts_as_label_system_label('#{sl}')
                    end
                    
                    alias_method :#{mn.upcase}, :#{mn}
                  end
                }
              end
              
              !!record
            end
            
            
            # This method finds an active record object for the given system label.
            #             
            def self.by_acts_as_label_system_label(system_label)
              where("#{acts_as_label_system_label_column} = ?", system_label.to_s.upcase).first
            end


            # This block adds a class method to return the default record.
            #
            unless self.method_defined? :default
              if default.nil?
                def self.default
                  self.first
                end
              else
                def self.default
                  self.send("#{acts_as_label_default_system_label}")
                end
              end
            end


            # This method overrides the system label column writer to force 
            # upcasing of the value.
            #
            define_method("#{acts_as_label_system_label_column}=") do |value| 
              value = value.to_s.strip.upcase unless value.nil?
              write_attribute("#{acts_as_label_system_label_column}", value)
            end
                          
            
            # Add all the instance methods
            include Coroutine::ActsAsLabel::Base::InstanceMethods

          end
        end  
      end

    
      module InstanceMethods
        
        # This method overrides to_ary to return nil, which tells anything trying to
        # flatten this we are already flat. This is necessary because we are overriding
        # active records method missing, which must do this somewhere in the bowels
        # of rails.
        #
        def to_ary
          nil
        end
        
        
        # This method overrides the to_s method to return the friendly label value.
        #
        def to_s
          self.send("#{acts_as_label_label_column}")
        end
        
        
        # This method overrides the to_sym method to return the downcased symbolized 
        # system label value. This method is particularly useful in conjunction with
        # role-based authorization systems.
        #
        def to_sym
          self.send("#{acts_as_label_system_label_column}").underscore.to_sym
        end
        
        
        # This method compares two values by running to_sym on both sides.  This allows
        # comparisons like the following:
        #   u.role == Role.superuser
        #   u.role == :superuser
        #
        def ==(other)
          self.to_sym == (other.to_sym rescue false)
        end
        
      end
    
    end
  end
end
