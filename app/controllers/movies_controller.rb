require 'set'

class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    need_redirection = false
    # pull all possible ratings from class method in Movie model
    @all_ratings = Movie.all_ratings_method

    # sort movies
    @by = params[:by] || session[:by] || ""
    # safeguarding malicious GET request
    @by, @class_title, @class_rd = case @by
      when "title" then ["title", "hilite", ""]
      when "release_date" then ["release_date", "", "hilite"]
      else ["", "", ""]
    end
    
    # initialize @rating so that all checkboxes are checked on fresh index
    @ratings = params[:ratings] || session[:ratings] || {}
    if @ratings == {}
      @ratings = @all_ratings.each { |rating| @ratings[rating] = "1"}
    end
    
    # on fresh page (and by default), display everything, unsorted
    @movies = Movie.all
    
    # sort the table according to 'title' or 'release_date'
    if params[:by] # use params[:by] to order
      session[:by] = params[:by]
    else
      need_redirection = true
    end
    
    # display only movies whose ratings = @ratings (could be from params or session)
    if params[:ratings]
      session[:ratings] = params[:ratings] # remember user choice
    else
      need_redirection = true
    end
    
    # redirect_to by: @by, ratings: @ratings
    if need_redirection
      redirect_to by: @by, ratings: @ratings 
    end
    
    @movies = Movie.where(rating: @ratings.keys).order(@by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
