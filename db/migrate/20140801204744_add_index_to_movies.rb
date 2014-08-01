class AddIndexToMovies < ActiveRecord::Migration
  def change
    add_index :movies, :imdb_id
  end
end
