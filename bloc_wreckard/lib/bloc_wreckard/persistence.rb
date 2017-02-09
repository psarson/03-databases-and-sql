require 'sqlite3'
require_relative 'schema'

module Persistence

  def self.included(base)
     base.extend(ClassMethods)
   end

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

    def update_attribute(attribute, value)
      self.class.update(self.id, { attribute => value })
    end

    def update_attributes(updates)
      self.class.update(self.id, updates)
    end

    def destroy
      self.class.destroy(self.id)
    end

    def destory_all
      ids = self.map(&:id)
      self.class.destroy(ids)
    end

    def update_attribute(attribute, value)
      self.class.update(self.id, { attribute => value })
    end

    def update_attributes(updates)
      self.class.update(self.id, updates)
    end

  module ClassMethods

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

   def update(ids, updates)
       updates = BlocWreckard::Utility.convert_keys(updates)
       updates.delete "id"
       updates_array = updates.map { |key, value| "#{key}=#{BlocWreckard::Utility.sql_strings(value)}" }

       if ids.class == Fixnum
         where_clause = "WHERE id = #{ids};"
       elsif ids.class == Array
         where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
       else
         where_clause = ";"
       end

      if updates.length > 1
        updates_array = []
        updates.map do |hash|
          updates_array << hash.map { |key, value|  "#{key}=#{BlocWreckard::Utility.sql_strings(value)}" }
        end
      end

      connection.execute <<-SQL
         UPDATE #{table}
         SET #{updates_array * ","} #{where_clause}
       SQL

       true
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

     def destroy_all(conditions=nil)
       if conditions
         case conditions
         when Hash
           if !conditions.empty?
           conditions_hash = BlocWreckard::Utility.convert_keys(conditions)
           conditions_array = conditions.map {|key, value| "#{key}=#{BlocWreckard::Utility.sql_strings(value)}"}.join(" and ")

           connection.execute <<-SQL
             DELETE FROM #{table}
             WHERE #{conditions_array};
           SQL
         else
           connection.execute <<-SQL
             DELETE FROM #{table}
           SQL
         end
         when String
           conditions_string = BlocWreckard::Utility.sql_strings(conditions)
           connection.execute <<-SQL
             DELETE FROM #{table}
             WHERE #{conditions_string};
           SQL
           else
             connection.execute <<-SQL
               DELETE FROM #{table}
             SQL
         when Array
           if !conditions.empty?
           conditions_array = conditions.map {|el| "#{BlocWreckard::Utility.sql_strings(el)}"}
           connection.execute <<-SQL
             DELETE FROM #{table}
             WHERE #{conditions_array};
           SQL
           else
             connection.execute <<-SQL
               DELETE FROM #{table}
            SQL
           end
         end
        end
      true
     end


     private

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
