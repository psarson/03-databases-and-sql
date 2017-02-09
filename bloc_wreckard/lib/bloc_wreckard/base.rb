#$LOAD_PATH.unshift(File.dirname(__FILE__))

# Users of our ORM will subclass Base when creating their model objects.

require 'bloc_wreckard/utility'
require 'bloc_wreckard/schema'
require 'bloc_wreckard/persistence'
require 'bloc_wreckard/selection'
require 'bloc_wreckard/connection'
require 'bloc_wreckard/collection'

module BlocWreckard
  class Base
     include Persistence
     extend Selection
     extend Schema
     extend Connection

     def initialize(options={})
       options = BlocWreckard::Utility.convert_keys(options)

       self.class.columns.each do |col|
         self.class.send(:attr_accessor, col)
         self.instance_variable_set("@#{col}", options[col])
       end
     end
   end
 end
