class PagesController < ApplicationController
  def home 
    render json: {online: true}
  end
end