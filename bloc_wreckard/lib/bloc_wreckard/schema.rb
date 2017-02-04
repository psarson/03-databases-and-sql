require 'sqlite3'
require 'bloc_wreckard/utility'

# Incudling this class will allow us to call 'table', 'schema', as well as the names of each
# column in the table.

module Schema
  # This method will allow us to call 'table' on an object to retrieve its SQL table name.
  def table
     BlocWreckard::Utility.underscore(name)
   end

   # Iterates through the columns in a database table. The method '.table_info(table)'
   # is a PRAGMA statement that retrieves information on the table data. This is stored as a hash
   # by the instance variable '@schema'
   #
   # ex.
   # @schema =>  {"id"=>"integer", "name"=>"text", "phone_number"=>"integer"}

   def schema
     unless @schema
       @schema = {}
       connection.table_info(table) do |col|
         @schema[col["name"]] = col["type"]
       end
     end
     @schema
   end

   # With the schema method in place, one can retrieve the columns as keys
   # returned as an array of strings
   def columns
     schema.keys
   end

   # Or the columns minus the id number (again as an array).
   def attributes
    columns - ["id"]
  end

  # Returns total number of records (rows) from a given SQL table.
  #
  # 'connection' is called to retrieve the Database object. The execute method, a SQLite3::Database instance method,
  # takes a query statement and returns a row of arrays. In this case,
  # our SQL query is bound by a 'heredoc' operator, storing everything between 'SQL's' as a string,
  # thus allowing SQLite3's to understand the arguments we are passing it.
  #
  # COUNT returns the total number of rows in a table,
  # [0][0] extracts the first column of the first row, which will contain the count.
  def count
     connection.execute(<<-SQL)[0][0]
       SELECT COUNT(*) FROM #{table}
     SQL
   end

end
