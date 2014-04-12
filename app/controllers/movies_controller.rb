require 'get_subtitles'

class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :find_query, only: [:show, :fulltext]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url }
      format.json { head :no_content }
    end
  end

  def fulltext

    unless @results.try(:results).try(:any?)
      redirect_to root_path(query: params[:query]), alert: 'Could not find any Movie with your query... Try again!'
    end

  end

  def find
    sub = FetchSubtitle.new.search params[:query]

    if sub
      begin
        @movie = Movie.find_by(imdb_id: sub.raw_data["IDMovieImdb"])
        @movie ||= Movie.create_from_sub(sub)
        render :show
      rescue Zlib::GzipFile::Error => e
        redirect_to movies_path(query: params[:query]), alert: 'Leech Limit reached... Try again!'
      end
    else
      redirect_to movies_path(query: params[:query]), alert: 'Error processing Movie... Try again!'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:content, :imdb_id, :year, :filename, :imdb_rating, :name)
    end

    def find_query
      return unless params[:query] && params[:query] != ''

      movie = @movie
      @results = Movie.search do

        fulltext params[:query] do
          highlight :content, :max_snippets => 1000

          phrase_fields :content => 4.0
        end

        paginate :per_page => 30

        with(:movie_id, movie.id) if movie

        # Order
        order_by(:score, :desc)
      end
    end
end
