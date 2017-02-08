module BlocWreckard
  # to check syntax, $ ruby -c filename.rb
   module Utility
     # In this context, self refers to the Utility class, making this module's method's
     # class methods, rather than instance methods. 
     extend self

     # Converts TextLikeThis into text_like_this in order to maintain proper naming conventions.
     # SQL table names are snake case (like_this).
     def underscore(camel_cased_word)
        string = camel_cased_word.gsub(/::/, '/')
        string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        string.tr!("-", "_")
        string.downcase
     end

     # This method returns a given value as a string or null. SQL does not recognize
     # any other value but strings.
     def sql_strings(value)
       case value
       when String
         "'#{value}'"
       when Numeric
         value.to_s
       else
         "null"
       end
     end

     # convert_keys() takes an 'options' hash and converts all the keys to string keys.
     #
     # An 'options' hash is a special type of ruby argument that has the default
     # value of an empty hash '{}'
     #
     # ** arguments passed to the 'options' hash must be passed as hash
     #  ex: def opts(options), opts(1, 2, 3) would return
     #      'wrong number of arguments (given 3, expected 1)'

     def convert_keys(options)
       options.keys.each { |k| options[k.to_s] = options.delete(k) if k.kind_of?(Symbol) }
       options
     end

     # instance_variables_to_hash() does the opposite of our initialize method, converts instance variable and it's value to a hash.
     # Because ruby loves to make things easy, the instance variables can be retrieved by calling
     # 'instance_variables' and 'instance_variable_get' on a given object.
     #
     # As told by APIdock/ruby/Object:
     #
     # .instance_variable_get
     #
     # Returns the value of the given instance variable, or nil if the instance variable is not set.
     # The @ part of the variable name should be included for regular instance variables.
     # Throws a NameError exception if the supplied symbol is not valid as an instance variable name.
     #
     #  ex. class Obj
     #        def initialize(p1, p2)
     #          @a, @b = p1, p2
     #        end
     #      end
     #
     #      big_O = Obj.new('cat', 99)
     #      big_O.instance_variable_get(:@a) => 'cat'
     #      big_O.instance_variable_get(":@b") => 99
     #
     # .instance_variables
     #
     # Returns an array of instance variable names as symbols (ex. [:@a, :@b]) for the receiver.
     # Note that simply defining an accessor does not create the corresponding instance variable.
     #
     #  ex. big_O.instance_variables
     #  =>  [:@a, :@b]


     def instance_variables_to_hash(obj)
       Hash[ obj.instance_variables.map { |var| [ "#{var.to_s.delete('@')}", obj.instance_variable_get(var.to_s) ] } ]
     end

     # 'reload_obj' takes an object (in this case, a database object), finds its database record
     #  using the find method in the Selection module.
     #
     #  Calling .class returns the class of obj. This method must always be called with
     #  an explicit receiver, as class is also a reserved word in Ruby.
     #
     #
     #
     #   def reload_obj(dirty_obj)
     #      persisted_obj = dirty_obj.class.find_one(dirty_obj.id)
     #
     #  It then retrieves the instance_variables of the 'dirty_obj' and iterates over them,
     #  using the setter method .instance_variable_set() to overwrite the old data, replacing it
     #  with the data returned by .instance_variable_get

     def reload_obj(dirty_obj)
       persisted_obj = dirty_obj.class.find_one(dirty_obj.id)
       dirty_obj.instance_variables.each do |instance_variable|
         dirty_obj.instance_variable_set(instance_variable, persisted_obj.instance_variable_get(instance_variable))
       end
     end

   end
 end
