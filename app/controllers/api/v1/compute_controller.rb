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
    case params[:compute][:gameState]
    when "DEAL" 
      # hand value is nothing
      # best plays is nothing
      # calculate payouts 
      # update credits
      render json: {status: "IN DEAL"}
    when "DRAW"
      # calculate hand value
      value = getHandValue
      # calculate odds
      # calculate best plays
      render json: {status: "IN DRAW", handValue: value}
    end
  end

  private 

  def getHandValue
    handValue = "Nothing"
    return handValue
  end
end
