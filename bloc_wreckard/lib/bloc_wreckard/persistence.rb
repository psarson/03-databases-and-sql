require 'sqlite3'
require_relative 'schema'

module Persistence
  # A few quick notes about self:
  # 'self' is the "current object" and the default receiver of messages
  # (method calls) for which no explicit receiver is specified.

  # '.included()' callback is invoked whenever the receiver is included in another module or class.
  # This should be used in preference to Module.append_features if your code wants
  # to perform some action when a module is included in another.
  def self.included(base)
     base.extend(ClassMethods)
   end

  #         THESE ARE INSTANCE METHODS
  #                 vvvvvvvvv
  # update_attribute passes self.class.update its own id and a hash
  # of the attributes that should be updated.

  # ex.
  # p = Person.first
  # p.update_attribute(:name, "Ben")

  def update_attribute(attribute, value)
    self.class.update(self.id, { attribute => value })
  end

  #plural version of update_attribute, takes an array of hashes

  def update_attributes(updates)
    self.class.update(self.id, updates)
  end

  def destroy
     self.class.destroy(self.id)
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

   # 'update(id, updates)' takes id and a column, row value hash, converts them to SQL format. Using the
   # UPDATE clause, the row in question is changed to reflect the new values. Returns
   # Boolean true

   def update(ids, updates)
       #Convert the non-id parameters to an array.
       updates = BlocWreckard::Utility.convert_keys(updates)
       updates.delete "id"

       #  Logic statements determine class type of ids
       #  We are appending ids in the form of a string to the WHERE clause.
       if ids.class == Fixnum
         where_clause = "WHERE id = #{ids};"
       elsif ids.class == Array
         where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
       else
         where_clause = ";"
       end

       #Use map to convert updates to an array of strings where each string
       #is in the format "KEY=VALUE". This updates the specified columns in the database.
        if updates.length == 1
          updates_array = updates.map { |key, value| "#{key}=#{BlocWreckard::Utility.sql_strings(value)}" }
        else
          updates_array = []

          updates.map do |hash|
            updates_array << hash.map { |key, value|  "#{key}=#{BlocWreckard::Utility.sql_strings(value)}" }
          end
        end
       #we build a fully formed SQL statement to update the database
       #and execute it using connection.execute
       connection.execute <<-SQL
         UPDATE #{table}
         SET #{updates_array * ","}
         WHERE id = #{id};
       SQL

       true
       # When this string is interpolated it will be a fully formed SQL statement with this format:
       #    UPDATE table_name
       #    SET column1=value1, column2=value2, ...
       #    WHERE id=id1;
       # method will return true
     end

     def update_all(updates)
       update(nil, updates)
     end

     def destroy(*id)
       if id.length > 1
         where_clause = "WHERE id IN (#{id.join(",")});"
       else
         where_clause = "WHERE id = #{id.first};"
       end

       connection.execute <<-SQL
         DELETE FROM DELETE FROM #{table} #{where_clause}
       SQL

       true
     end

     def destroy_all(conditions_hash=nil)
       if conditions_hash && !conditions_hash.empty?
         conditions_hash = BlocRecord::Utility.convert_keys(conditions_hash)
         conditions = conditions_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")

         connection.execute <<-SQL
           DELETE FROM #{table}
           WHERE #{conditions};
         SQL
       else
         connection.execute <<-SQL
           DELETE FROM #{table}
         SQL
       end 
       true
     end

     def self.method_missing(method_sym, *arguments, &block)
       if method_sym.to_s =~ /^update_name(.*)$/
         update($1.to_sym => arguments.first)
       else
         super
       end
     end

     def self.respond_to?(method_sym, include_private = false)
       if method_sym.to_s =~ /^update_name(.*)$/
         true
       else
         super
       end
     end

end
