class HomeController < ApplicationController
  def index
    render json: {message: 'airbnb clone'}
  end
end
