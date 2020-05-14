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
    handValue = "Nothing"
    sortedHand = hand.sort_by { |card| card["i"] }
    
    # Check for straight
    straight = false;
    high = nil
    if sortedHand[0]["i"] == 1 
      if sortedHand[1]["i"] == 2 && sortedHand[2]["i"] == 3 && sortedHand[3]["i"] == 4 && sortedHand[4]["i"] == 5
        straight = true
        high = "5"
      end
      if sortedHand[4]["i"] == 13 && sortedHand[3]["i"] == 12 && sortedHand[2]["i"] == 11 && sortedHand[1]["i"] == 10
        straight = true
        high = "A"
      end
    end
    if sortedHand[1]["i"] == sortedHand[0]["i"] + 1 && sortedHand[2]["i"] == sortedHand[1]["i"] + 1 &&
       sortedHand[3]["i"] == sortedHand[2]["i"] + 1 && sortedHand[4]["i"] == sortedHand[3]["i"] + 1 &&
      straight = true 
      high = sortedHand[4]["v"]
    end


    # Check for flush
    flush = false

    if sortedHand[0]["s"] == sortedHand[1]["s"] && sortedHand[1]["s"] == sortedHand[2]["s"] && 
       sortedHand[2]["s"] == sortedHand[3]["s"] && sortedHand[3]["s"] == sortedHand[4]["s"]
       flush = true
    end 

    # Royal Flush
    if straight && flush && high == "A"
      return "Royal Flush"
    end

    # Straight Flush 
    if straight && flush 
      return "Straight Flush #{high} High"
    end

    # 4 of a kind
    if sortedHand[0]["i"] == sortedHand[1]["i"] && sortedHand[1]["i"] == sortedHand[2]["i"] && sortedHand[2]["i"] == sortedHand[3]["i"] ||
       sortedHand[1]["i"] == sortedHand[2]["i"] && sortedHand[2]["i"] == sortedHand[3]["i"] && sortedHand[3]["i"] == sortedHand[4]["i"] 
       return "Four of a Kind #{sortedHand[3]["v"]}s"
    end


    #Full House
    if sortedHand[0]["i"] == sortedHand[1]["i"] && sortedHand[2]["i"] == sortedHand[3]["i"] && sortedHand[3]["i"] == sortedHand[4]["i"]
      return "Full House #{sortedHand[3]["v"]}s Full of #{sortedHand[0]["v"]}s"
    end
    if sortedHand[0]["i"] == sortedHand[1]["i"] && sortedHand[1]["i"] == sortedHand[2]["i"] && sortedHand[3]["i"] == sortedHand[4]["i"]
      return "Full House #{sortedHand[0]["v"]}s Full of #{sortedHand[3]["v"]}s"
    end
    

    # Flush 
    if flush
      return "Flush A High" if sortedHand[0]["i"] == 1 
      return "Flush #{sortedHand[4]["v"]} High"
    end


    # Straight
    if straight 
      return "Straight #{high} High"
    end

    # Three of a Kind
    return "Three of a Kind #{sortedHand[0]["v"]}s" if sortedHand[0]["v"] == sortedHand[1]["v"] && sortedHand[1]["v"] == sortedHand[2]["v"]
    return "Three of a Kind #{sortedHand[1]["v"]}s" if sortedHand[1]["v"] == sortedHand[2]["v"] && sortedHand[2]["v"] == sortedHand[3]["v"]
    return "Three of a Kind #{sortedHand[2]["v"]}s" if sortedHand[2]["v"] == sortedHand[3]["v"] && sortedHand[3]["v"] == sortedHand[4]["v"]


    # Two Pair 
    twoPair = false

    twoPair = true if sortedHand[0]["v"] == sortedHand[1]["v"] && sortedHand[2]["v"] == sortedHand[3]["v"] 
    twoPair = true if sortedHand[0]["v"] == sortedHand[1]["v"] && sortedHand[3]["v"] == sortedHand[4]["v"] 
    twoPair = true if sortedHand[1]["v"] == sortedHand[2]["v"] && sortedHand[3]["v"] == sortedHand[4]["v"] 
    if twoPair
      if sortedHand[1]["v"] == "A" 
        return "Two Pair As over #{sortedHand[3]["v"]}s"
      elsif sortedHand[3]["v"] == "A"
        return "Two Pair As over #{sortedHand[1]["v"]}s"
      else
        return "Two Pair #{sortedHand[3]["v"]}s over #{sortedHand[1]["v"]}s" 
      end
    end


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
