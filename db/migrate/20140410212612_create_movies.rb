class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.text :content
      t.string :imdb_id
      t.string :year
      t.string :filename
      t.string :imdb_rating
      t.string :name

      t.timestamps
    end
  end
end
