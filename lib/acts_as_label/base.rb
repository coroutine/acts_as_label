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
            
            # Add inheritable accessors
            write_inheritable_attribute :acts_as_label_system_label_column,   system_label
            class_inheritable_reader    :acts_as_label_system_label_column
            write_inheritable_attribute :acts_as_label_label_column,          label
            class_inheritable_reader    :acts_as_label_label_column
            write_inheritable_attribute :acts_as_label_scope,                 scope
            class_inheritable_reader    :acts_as_label_scope
            write_inheritable_attribute :acts_as_label_default_system_label,  default
            class_inheritable_reader    :acts_as_label_default_system_label
          
            
            # protect attributes
            attr_readonly               system_label
            
            
            # Add validations
            validates_presence_of       system_label
            validates_length_of         system_label,  :maximum   => 255
            validates_format_of         system_label,  :with      => /^[A-Z][_A-Z0-9]*$/
            validates_presence_of       label
            validates_length_of         label,         :maximum => 255
            
            
            # Add method missing, if needed
            unless self.method_defined? :method_missing
              def self.method_missing(method, *args, &block)
                super
              end
            end
            
            # Add custom method missing functionality to perform find by system label lookup. If 
            # nothing is found, it delegates the call to the original method_missing.
            #
            # The method attempts rails 3 syntax. If that fails, it reverts to rails 2 syntax.
            def self.method_missing_with_label(method, *args, &block)
              begin
                record = self.where("#{acts_as_label_system_label_column} = ?", method.to_s.upcase).first
              rescue
                record =  self.find(:first, :conditions => ["#{acts_as_label_system_label_column} = ?", method.to_s.upcase])
              end
              if record
                return record
              else
                method_missing_without_label(method, *args, &block)
              end
            end
            
            # Add method missing alias
            class << self
              alias_method_chain :method_missing, :label       
            end
               
            # Add class method to return default record, if needed
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
            
            
            # Add all the instance methods
            include Coroutine::ActsAsLabel::Base::InstanceMethods

          end
        end  
      end

    
      module InstanceMethods
      
        # This method updates the system label attribute writer to ensure it is uppercase.
        #
        def system_label=(value)
          value = value.to_s.strip.upcase unless value.nil?
          write_attribute("#{acts_as_label_system_label_column}", value)
        end
        
        
        # This method overrides the to_s method to return the friendly label value.
        #
        def to_s
          self.send("#{acts_as_label_label_column}")
        end
        
        
        # This method overrides the to_sym method to return the downcased symbolized 
        # system label value.  This method is particularly useful in conjunction with
        # role-based authorization systems.
        #
        def to_sym
          self.send("#{acts_as_label_system_label_column}").downcase.to_sym
        end
        
      end
    
    end
  end
end
