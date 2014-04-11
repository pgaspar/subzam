class FrontController < ApplicationController
  def index
    @movies = Movie.all
  end
end
