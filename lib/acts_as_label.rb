module Coroutine                      #:nodoc:
  module Acts                         #:nodoc:
    module Label                      #:nodoc: 

      def self.included(base)         #:nodoc:
        base.extend(ClassMethods)
      end

      
      # = Description
      #
      # This +acts_as+ extension implements a system label and a friendly label on a class and centralizes
      # the logic for performing validations and accessing items by system label.
      #
      # = Simple Example:
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
      # = STI Example:
      #
      #   class Label < ActiveRecord::Base
      #     acts_as_label
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
      module ClassMethods
      
        
        # Configuration options are:
        #
        # * +system_label_cloumn+ - specifies the column name to use for storing the system label (default: +system_label+)
        # * +label_column+ - specifies the column name to use for storing the label (default: +label+)
        # * +default+ - specifies the system label value of the default instance (default: the first record in the default scope)
        # 
        def acts_as_label(options = {})
          
          #-------------------------------------------
          # scrub options
          #-------------------------------------------
          system_label  = options.key?(:system_label_column)  ? options[:system_label_column].to_sym  : :system_label
          label         = options.key?(:label_column)         ? options[:label_column].to_sym         : :label
          default       = options.key?(:default)              ? options[:default].to_sym              : nil
                    
          
          #--------------------------------------------
          # mix methods into class definition
          #--------------------------------------------
          class_eval do
            
            # Add inheritable accessors
            write_inheritable_attribute :system_label_column,   system_label
            class_inheritable_reader    :system_label_column
            write_inheritable_attribute :label_column,          label
            class_inheritable_reader    :label_column
            write_inheritable_attribute :default_system_label,  default
            class_inheritable_reader    :default_system_label
          
            
            # Add validations
            validates_presence_of       system_label
            validates_length_of         system_label,  :maximum => 255
            validates_format_of         system_label,  :with    => /^[A-Z][_A-Z0-9]*$/
            validates_presence_of       label
            validates_length_of         label,         :maximum => 255
            
            # Add callbacks
            before_validation           :upcase_system_label_value
            
            
            # Add method missing, if needed
            unless self.method_defined? :method_missing
              def self.method_missing(method, *args, &block)
                super
              end
            end
            
            # Add custom method missing functionality to perform find by system label lookup. If 
            # nothing is found, it delegates the call to the original method_missing.
            def self.label_method_missing(method, *args, &block)
              record = BillingFrequency.find(:first, :conditions => ["#{system_label_column} = ?", method.to_s.upcase])
              if record
                return record
              else
                old_method_missing(method, *args, &block)
              end
            end
            
            # Add method missing alias
            class << self
              alias_method :original_method_missing,  :method_missing
              alias_method :method_missing,           :label_method_missing
            end
               
            # Add class method to return default record, if needed
            unless self.method_defined? :default
              if default.nil?
                def self.default
                  self.first
                end
              else
                def self.default
                  self.send("#{default_system_label}")
                end
              end
            end
            
            
            # Add all the instance methods
            include InstanceMethods

          end
          
        end  
      end



      #--------------------------------------------------------------------------------------------
      # These methods are mixed into any instance of a class that implements +acts_as_label+.
      #--------------------------------------------------------------------------------------------
      module InstanceMethods
        
        # This method overrides the to_s method to return the friendly label value.
        #
        def to_s
          self.send("#{label_column}")
        end
        
        
        private
        
        # This method updates the system label attribute to ensure it is uppercase.
        #
        def upcase_system_label_value
          update_attribute("#{system_label_column}", self.send("#{system_label_column}").to_s.upcase)
        end
      
      end 
    end
  end
end