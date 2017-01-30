require 'sqlite3'

module Selection
  def find(*ids)
    if !ids.is_a? Array
      puts "Invalid Input"
      return false
    end

    if !ids.all? {|i| i.is_a? Integer}
      puts "Invalid id number"
      return false
    end

    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)
     if id < 0
       puts "Invalid id number"
       return false
     end

     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       WHERE id = #{id};
      SQL

      init_object_from_row(row)
   end

   def find_by(attribute, value)
       row = connection.get_first_row <<-SQL
         SELECT #{columns.join ","} FROM #{table}
         WHERE #{attribute} = #{BlocWreckard::Utility.sql_strings(value)};
       SQL

       init_object_from_row(row)
   end

   def find_each(options)
     rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       LIMIT #{options[:batch_size]};
     SQL

     rows_to_array(rows).each { |row| yield(row) }
   end

   def find_batch(options)
     rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       LIMIT #{options[:batch_size]};
     SQL

    yield rows_to_array(rows)

   end

   def take(num=1)
     if num > 1
       rows = connection.execute <<-SQL
         SELECT #{columns.join ","} FROM #{table}
         ORDER BY random()
         LIMIT #{num};
       SQL

       rows_to_array(rows)
     else
       take_one
     end
   end

   def take_one
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY random()
       LIMIT 1;
     SQL

     init_object_from_row(row)
   end

   def first
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY id
       ASC LIMIT 1;
     SQL

     init_object_from_row(row)
   end

   def last
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY id
       DESC LIMIT 1;
     SQL

     init_object_from_row(row)
   end

   def all
     rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table};
     SQL

     rows_to_array(rows)
   end

   def method_missing(m, *args, &block)
      if m == :find_by_name && args.length == 1
        find_by(:name, args[0])
      end
    end

   private
   # Allow us to retrieve records if we know the values of other attribues
   def init_object_from_row(row)
     if row
       data = Hash[columns.zip(row)]
       new(data)
     end
   end

   def rows_to_array(rows)
     rows.map { |row| new(Hash[columns.zip(row)]) }
   end
end
