module BlocRecord

  #ex. Person.where(boat: true).update_all(boat: false)
  # Will update all rows so that boat is false
   class Collection < Array
     # we define update_all to take an array, updates.
     # ex.
     #  update_all( [{boat: false}] )
     def update_all(updates)
       #set ids using self.map
       ids = self.map(&:id)
      
       self.any? ? self.first.class.update(ids, updates) : false
       #  if there are items in Collection then we call the class method
       #  self.first.class.update(ids,updates) with the array of ids and
       #  hash of updates as parameters.
     end
   end
 end
