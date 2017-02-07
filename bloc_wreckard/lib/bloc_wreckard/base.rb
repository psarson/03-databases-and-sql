#$LOAD_PATH.unshift(File.dirname(__FILE__))

# Users of our ORM will subclass Base when creating their model objects.

require 'bloc_wreckard/utility'
require 'bloc_wreckard/schema'
require 'bloc_wreckard/persistence'
require 'bloc_wreckard/selection'
require 'bloc_wreckard/connection'
require 'bloc_record/collection'

module BlocWreckard
  class Base
     # The methods in a module may be instance methods or module methods.
     # Instance methods appear as methods in a class when the module is included, module methods do not.
     include Persistence

     # extend (-ing) a module makes its class methods available
     extend Selection
     extend Schema
     extend Connection
     extend Collection

     # After filtering the options hash using convert_keys, this method iterates over each column.
     # This method uses self.class to get the class's dynamic, runtime type, and calls columns on that type.

     # Use Object::send to send the column name to attr_accessor.
     # This creates an instance variable getter and setter for each column.

     # Use Object::instance_variable_set to set the instance variable to the
     # value corresponding to that key in the options hash.

     # ex. options = {"character_name"=>"Jar-Jar Binks"}
     # the key character_name would be converted to an instance variable
     # with the value "Jar-Jar Binks"
     # - or -
     # @character_name = "Jar-Jar Binks"

     def initialize(options={})
       options = BlocWreckard::Utility.convert_keys(options)

       self.class.columns.each do |col|
         self.class.send(:attr_accessor, col)
         self.instance_variable_set("@#{col}", options[col])
       end
     end
   end
 end
