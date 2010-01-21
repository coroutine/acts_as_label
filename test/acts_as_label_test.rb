#---------------------------------------------------------
# Requirements
#---------------------------------------------------------

# require active record
require "rubygems"
gem     "activerecord", ">= 2.3.2"
require "active_record"


# require test stuff and plugin
require "test/test_helper"
require "test/unit"
require "#{File.dirname(__FILE__)}/../init"



#---------------------------------------------------------
# Database config
#---------------------------------------------------------

# establish db connection
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")


# define and seed tables
def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :labels do |t|
      t.string  :type,          :limit => 255
      t.string  :system_label,  :limit => 255
      t.string  :label,         :limit => 255
      
      t.timestamps
    end
    
    create_table :frameworks do |t|
      t.string  :system_name,   :limit => 255
      t.string  :name,          :limit => 255
      
      t.timestamps
    end
  end
  
  Role.create!({ :system_label => "SUPERUSER",  :label => "Admin" })
  Role.create!({ :system_label => "EMPLOYEE",   :label => "Employee" })
  Role.create!({ :system_label => "GUEST",      :label => "Guest" })
  
  BillingFrequency.create!({ :system_label => "MONTHLY",    :label => "Monthly" })
  BillingFrequency.create!({ :system_label => "QUARTERLY",  :label => "Quarterly" })
  
  Framework.create!({ :system_name => "RUBY_ON_RAILS",  :name => "Rails" })
  Framework.create!({ :system_name => "DJANGO",         :name => "Django" })
end


# drop all tables
def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end



#---------------------------------------------------------
# Model definitions
#---------------------------------------------------------

# Labels (STI base)
class Label < ActiveRecord::Base
  acts_as_label
end


# Roles (STI extension with default)
class Role < Label
  def self.default
    Role.guest
  end
end


# BillingFrequency (STI extension without default)
class BillingFrequency < Label
end


# Frameworks (stand-alone model with overrides)
class Framework < ActiveRecord::Base
  acts_as_label :system_label_column => :system_name, :label_column => :name, :default => :ruby_on_rails
end



#---------------------------------------------------------
# Tests
#---------------------------------------------------------

class ActsAsLabelTest < Test::Unit::TestCase

  #---------------------------------------------
  # setup and teardown delegations
  #---------------------------------------------
  
  def setup
    setup_db
  end
  def teardown
    teardown_db
  end



  #---------------------------------------------
  # test validations
  #---------------------------------------------
  
  def test_validations_with_standard_columns
    
    # get valid record
    record = Role.new({ :system_label => "CUSTOMER",  :label => "Client" })
    assert record.valid?
    
    # system label cannot be null
    record.system_label = nil               
    assert !record.valid?
    
    # system label cannot be blank
    record.system_label = ""               
    assert !record.valid?
    
    # system label cannot be longer than 255 characters
    record.system_label = ""                
    256.times { record.system_label << "x" }
    assert !record.valid?
    
    # system label cannot have illegal characters
    record.system_label = "SUPER-USER"
    assert !record.valid?
    
    # reset system label
    record.system_label = "CUSTOMER"
    assert record.valid?
    
    # label cannot be null
    record.label = nil               
    assert !record.valid?
     
    # label cannot be blank
    record.label = ""               
    assert !record.valid?
    
    # label cannot be longer than 255 characters
    record.label = ""                
    256.times { record.label << "x" }
    assert !record.valid?
    
  end
  
  
  def test_validations_with_custom_columns
    
    # get valid record
    record = Framework.new({ :system_name => "SPRING",  :name => "Spring" })
    assert record.valid?
    
    # system name cannot be null
    record.system_name = nil               
    assert !record.valid?
    
    # system name cannot be blank
    record.system_name = ""               
    assert !record.valid?
    
    # system name cannot be longer than 255 characters
    record.system_name = ""                
    256.times { record.system_name << "x" }
    assert !record.valid?
    
    # system name cannot have illegal characters
    record.system_name = "SPRING-JAVA"
    assert !record.valid?
    
    # reset system name
    record.system_name = "SPRING"
    assert record.valid?
    
    # name cannot be null
    record.name = nil               
    assert !record.valid?
     
    # name cannot be blank
    record.name = ""               
    assert !record.valid?
    
    # name cannot be longer than 255 characters
    record.name = ""                
    256.times { record.name << "x" }
    assert !record.valid?
    
  end
  
  
  #---------------------------------------------
  # test method missing
  #---------------------------------------------
  
  def test_method_missing_accessors
    
    # test lookup by system label
    assert_equal Role.find(:first, :conditions => ["system_label = ?", "SUPERUSER"]), Role.superuser
    
    # test default with implemented method
    assert_equal Role.find(:first, :conditions => ["system_label = ?", "GUEST"]), Role.default
    
    # test default with unspecified behavior
    assert_equal BillingFrequency.first, BillingFrequency.default
    
    # test default with specified system label
    assert_equal Framework.find(:first, :conditions => ["system_name = ?", "RUBY_ON_RAILS"]), Framework.default
    
  end
  
  
  def test_method_missing_finders
    
    # dynamic find on stand-alone model
    record = Framework.find_by_system_name("RUBY_ON_RAILS")
    assert !record.nil?
    
    #dynamic find on sti model
    record = Role.find_by_system_label("SUPERUSER")
    assert !record.nil?
    
  end
  
  
  
  #---------------------------------------------
  # test instance methods
  #---------------------------------------------
  
  def test_to_s
    role = Role.first
    assert_equal role.label, role.to_s
  end
  
  
  def test_upcase_system_label_value
    record = Role.create!({ :system_label => "Customer",  :label => "Client" })
    assert_equal record.system_label, "CUSTOMER"
  end

end
