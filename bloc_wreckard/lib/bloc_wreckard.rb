module BlocWreckard

  # When a user of BlocWreckard calls BlocWreckard.connect_to('data.db'),
  # this filename will be stored for later.

   def self.connect_to(filename)
     @database_filename = filename
   end

   # BlocWreckard.connect_to("db/address_bloc.sqlite") => File name is now stored. 

   def self.database_filename
     @database_filename
   end
 end
