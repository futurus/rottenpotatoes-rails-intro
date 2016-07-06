class Movie < ActiveRecord::Base
    def self.all_ratings_method
        ['G','PG','PG-13','R']
    end
end
