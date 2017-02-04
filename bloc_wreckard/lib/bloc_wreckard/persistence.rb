require 'sqlite3'
require_relative 'schema'

module Persistence
  # A few quick notes about self:
  # 'self' is the "current object" and the default receiver of messages
  # (method calls) for which no explicit receiver is specified.

  # '.included()' callback invoked whenever the receiver is included in another module or class.
  # This should be used in preference to Module.append_features if your code wants
  # to perform some action when a module is included in another.

  
  def self.included(base)
     base.extend(ClassMethods)
   end

  module ClassMethods
   def save
     self.save! rescue false
   end

   def save!
     unless self.id
       self.id = self.class.create(BlocWreckard::Utility.instance_variables_to_hash(self)).id
       BlocWreckard::Utility.reload_obj(self)
       return true
     end

     fields = self.class.attributes.map { |col| "#{col}=#{BlocWreckard::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

     self.class.connection.execute <<-SQL
       UPDATE #{self.class.table}
       SET #{fields}
       WHERE id = #{self.id};
     SQL

     true
   end

   # converts hash 'attrs' keys to string,
   # delete the attribute/column name 'id'
   # calling .map on the attributes method (which in turn calls columns, which in turn calls schema),
   # an array of values is created and converted to strings.

   # the () around #{attributes.join ","} specificy which column their corresponding values will be
   # inserted into.

   # finally, a new ruby Character object is created and returned in the form of the newly
   # created objects id

   def create(attrs)
       attrs = BlocWreckard::Utility.convert_keys(attrs)
       attrs.delete "id"
       vals = attributes.map { |key| BlocWreckard::Utility.sql_strings(attrs[key]) }

       connection.execute <<-SQL
         INSERT INTO #{table} (#{attributes.join ","})
         VALUES (#{vals.join ","});
       SQL

       data = Hash[attributes.zip attrs.values]
       data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
       new(data)
     end
   end
end
