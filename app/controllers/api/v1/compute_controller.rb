if Rails.env.development?
  require 'pry'
end

class API::V1::ComputeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    render json: {hello: true}
  end

  def sent
    # params[:compute] is everthing sent here
    render json: {"info": params[:compute]}
  end
end
