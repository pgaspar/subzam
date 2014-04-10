require 'get_subtitles'

class FrontController < ApplicationController
  def index
  end

  def search
    @sub = FetchSubtitle.new.search params[:query]
    redirect_to :root, alert: 'Error processing Movie... Try again!' unless @sub
  end
end
