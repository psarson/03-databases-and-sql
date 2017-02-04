require 'sqlite3'

 module Connection

   # In calling SQLite3::Database.new, you are creating a new Database Object
   # from the Database class in SQLite3, if you recall, BlocWreckard has saved
   # the file name of the App's database - when 'connection' is called, it returns
   # the instance variable @connection, which itself is an instance of the app's
   # database.

   def connection
     @connection ||= SQLite3::Database.new(BlocWreckard.database_filename)
   end
 end

  # so,
  #
  #  BlocWreckard.connect_to("db/address_bloc.sqlite") => File name is now stored.
  #
  #  FROM http://sqlite-ruby.rubyforge.org/:
  #
  #  Database.new( file_name, mode=0 )
  #
  #  Create a new Database object that opens the given file. The mode parameter has
  #  no meaning yet, and may be omitted. If the file does not exist, it will be
  #  created if possible. By default, the new database will return result rows as arrays
  #  (results_as_hash)
  #
  #  Since the '.new' method was passed the filename 'db/address_bloc.sqlite', it will
  #  open said file as a sqlite file.  
