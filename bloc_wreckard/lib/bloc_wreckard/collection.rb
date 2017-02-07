module BlocRecord

  #ex. Person.where(boat: true).update_all(boat: false)
  # Will update all rows so that boat is false
   class Collection < Array
     # we define update_all to take an array, updates.
     # ex.
     #  update_all( [{boat: false}] )
     def update_all(updates)
       # set ids using self.map
       # REMINDER bar(&:foo) == bar{|x| x.foo}
       ids = self.map(&:id)

       self.any? ? self.first.class.update(ids, updates) : false
       #  if there are items in Collection then we call the class method
       #  self.first.class.update(ids,updates) with the array of ids and
       #  hash of updates as parameters.
     end

     #to be called on instances of database objects
     # ex. Person.where(first_name: 'John').take
     # ex. Person.where(first_name: 'John').where(last_name: 'Smith');

     def take(num=1)
        self.any? ? self.first.class.take(num=1) : false
     end

     def where(*args)
       self.any? ? self.first.class.where(*args) : false
     end

     #  WHERE NOT QUERY:
     #  SELECT `users`.* FROM `users` WHERE (`users`.`id` != 1) AND (`users`.`name` IS NOT NULL)

     def not(*args)
       self.any? ? self.first.class.not(*args) : false
     end

   end
 end
