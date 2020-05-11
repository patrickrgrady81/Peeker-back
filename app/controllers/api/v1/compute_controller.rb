class API::V1::ComputeController < ApplicationController
  def index
    render json: {hello: true}
  end
end
