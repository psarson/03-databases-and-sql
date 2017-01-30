require 'sqlite3'
require_relative 'utility'


module Schema
  def table
     BlocWreckard::Utility.underscore(name)
   end

   def schema
     unless @schema
       @schema = {}
       connection.table_info(table) do |col|
         @schema[col["name"]] = col["type"]
       end
     end
     @schema
   end

   def columns
     schema.keys
   end

   def attributes
    columns - ["id"]
  end

  def count
     connection.execute(<<-SQL)[0][0]
       SELECT COUNT(*) FROM #{table}
     SQL
   end
end
