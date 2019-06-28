class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory],
      ),
    )
  end

  def create
    last_movie = Movie.all.max_by { |movie| movie.id }

    movie = Movie.new(movie_params)

    movie.id = last_movie.id + 1
    movie.image_url = "/" + movie.image_url.split("/").last

    if movie.save
      render status: :ok, json: {id: movie.id}
    else
      render status: :bad_request, json: {errors: movie.errors.messages}
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: {errors: {title: ["No movie with title #{params["title"]}"]}}
    end
  end

  def movie_params
    params.permit(:id, :external_id, :title, :overview, :release_date, :image_url, :inventory)
  end
end
