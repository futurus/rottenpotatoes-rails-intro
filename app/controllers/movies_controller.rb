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
    # for use with index.html.haml
    @all_ratings = Movie.get_ratings()
    redir = false
    
    # forcing RESTful routes
    if params.has_key?(:by)
      session[:by] = params[:by] # remember user choice
    else
      params[:by] = session.has_key?(:by) ? session[:by] : ""
      redir = true
    end
    
    if params.has_key?(:ratings)
      session[:ratings] = params[:ratings] # remember user choice
    else
      params[:ratings] = session.has_key?(:ratings) ? session[:ratings] : Hash[@all_ratings.map {|key| [key, "1"]}]
      redir = true
    end
    
    if redir
      redirect_to movies_path(:by => params[:by], :ratings => params[:ratings])
    end
    
    @title_header, @release_date_header = case params[:by]
      when "release_date"
        ["", "hilite"]
      when "title"
        ["hilite", ""]
      else
        ["", ""]
    end
    
    @movies = Movie.order(params[:by]).where(rating: params[:ratings].keys)
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
