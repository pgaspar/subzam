class AddPosterUrlToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :poster_url, :string
  end
end
