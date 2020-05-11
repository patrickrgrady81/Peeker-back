if Rails.env.development?
  require 'pry'
end

class API::V1::ComputeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    render json: {hello: true}
  end

  def sent
    render json: {"info": params[:compute]}
  end
end
