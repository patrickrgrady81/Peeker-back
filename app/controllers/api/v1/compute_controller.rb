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
    hand = params[:compute][:hand]
    case params[:compute][:gameState]
    when "DEAL" 
      # calculate hand value
      value = getHandValue(hand)
      # best plays is nothing
      # calculate payouts 
      # update credits
      render json: {status: "IN DEAL", handValue: value}
    when "DRAW"
      # calculate hand value
      value = getHandValue(hand)
      # calculate odds
      # calculate best plays
      render json: {status: "IN DRAW", handValue: value}
    end
  end

  private 

  def getHandValue(hand)
    #get the ids
    # ids = []
    handValue = "Nothing"

    sortedHand = hand.sort_by { |card| card["i"] }
    
    # Check for straight
    # Check for flush


    # One Pair
    for i in 0..3 do 
      if sortedHand[i]["v"] == sortedHand[i+1]["v"]
        return "Pair of #{sortedHand[i]["v"]}s"
      end
    end


    # High Card 
    handValue = "High Card #{sortedHand[4]["v"]}"
    handValue = "High Card Ace" if sortedHand[0]["i"] == 1
    return handValue
  end
end
