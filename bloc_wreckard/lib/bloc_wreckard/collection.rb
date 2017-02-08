module BlocWreckard

   class Collection < Array

     def update_all(updates)
       ids = self.map(&:id)
       self.any? ? self.first.class.update(ids, updates) : false
     end

     def take(num)
        self.any? ? self.first.class.take(num) : false
     end

     def where(*args)
       self.any? ? self.first.class.where(*args) : false
     end

   end

 end
