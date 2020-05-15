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
      val = getHandValue(hand)
      value = val[0]
      intValue = val[1]

      # best plays is nothing
      # calculate payouts 
      payout = getPayouts(intValue)
      # update credits
      render json: {status: "IN DRAW", handValue: value, payout: payout}
    when "DRAW"
      # calculate hand value
      
      val = getHandValue(hand)
      value = val[0]
      intValue = val[1]

      
      # binding.pry
      
      
      # calculate odds
      # calculate best plays
      render json: {status: "IN DRAW", handValue: value, payout: 0}
    end
  end
      
  private 

  def getHandValue(hand)
    handValue = "Nothing"
    intHandValue = 0
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
    
    # High Card 
    handValue = "High Card #{sortedHand[4]["v"]}"
    handValue = "High Card Ace" if sortedHand[0]["i"] == 1
    
    # One Pair
    for i in 0..3 do 
      if sortedHand[i]["v"] == sortedHand[i+1]["v"]
        intHandValue = 1
        handValue = "Pair of #{sortedHand[i]["v"]}s"
      end
    end
    
    # Two Pair 
    twoPair = false
    
    twoPair = true if sortedHand[0]["v"] == sortedHand[1]["v"] && sortedHand[2]["v"] == sortedHand[3]["v"] 
    twoPair = true if sortedHand[0]["v"] == sortedHand[1]["v"] && sortedHand[3]["v"] == sortedHand[4]["v"] 
    twoPair = true if sortedHand[1]["v"] == sortedHand[2]["v"] && sortedHand[3]["v"] == sortedHand[4]["v"] 
    if twoPair
      intHandValue = 2
      if sortedHand[1]["v"] == "A" 
        handValue = "Two Pair As over #{sortedHand[3]["v"]}s"
      elsif sortedHand[3]["v"] == "A"
        handValue = "Two Pair As over #{sortedHand[1]["v"]}s"
      else
        handValue = "Two Pair #{sortedHand[3]["v"]}s over #{sortedHand[1]["v"]}s" 
      end
    end
    
    # Three of a Kind
    if sortedHand[0]["v"] == sortedHand[1]["v"] && sortedHand[1]["v"] == sortedHand[2]["v"]
      intHandValue = 3
      handValue = "Three of a Kind #{sortedHand[0]["v"]}s" 
    end
    if sortedHand[1]["v"] == sortedHand[2]["v"] && sortedHand[2]["v"] == sortedHand[3]["v"]
      intHandValue = 3
      handValue = "Three of a Kind #{sortedHand[1]["v"]}s" 
    end
    if sortedHand[2]["v"] == sortedHand[3]["v"] && sortedHand[3]["v"] == sortedHand[4]["v"]
      intHandValue = 3
      handValue = "Three of a Kind #{sortedHand[2]["v"]}s" 
    end
    
    # Straight
    if straight 
      intHandValue = 4
      handValue = "Straight #{high} High"
    end

    # Flush 
    if flush
      intHandValue = 5
      handValue = "Flush A High" if sortedHand[0]["i"] == 1 
      handValue = "Flush #{sortedHand[4]["v"]} High"
    end  
    
    
    #Full House
    if sortedHand[0]["i"] == sortedHand[1]["i"] && sortedHand[2]["i"] == sortedHand[3]["i"] && sortedHand[3]["i"] == sortedHand[4]["i"]
      intHandValue = 6
      handValue = "Full House #{sortedHand[3]["v"]}s Full of #{sortedHand[0]["v"]}s"
    end
    if sortedHand[0]["i"] == sortedHand[1]["i"] && sortedHand[1]["i"] == sortedHand[2]["i"] && sortedHand[3]["i"] == sortedHand[4]["i"]
      intHandValue = 6
      handValue = "Full House #{sortedHand[0]["v"]}s Full of #{sortedHand[3]["v"]}s"
    end

    # 4 of a kind
    if sortedHand[0]["i"] == sortedHand[1]["i"] && sortedHand[1]["i"] == sortedHand[2]["i"] && sortedHand[2]["i"] == sortedHand[3]["i"] ||
      sortedHand[1]["i"] == sortedHand[2]["i"] && sortedHand[2]["i"] == sortedHand[3]["i"] && sortedHand[3]["i"] == sortedHand[4]["i"] 
      
      intHandValue = 7
      handValue = "Four of a Kind #{sortedHand[3]["v"]}s"
   end    

    # Straight Flush 
    if straight && flush 
      intHandValue = 8
      handValue = "Straight Flush #{high} High"
    end

    # Royal Flush
    if straight && flush && high == "A"
      intHandValue = 9
      handValue = "Royal Flush"
    end    

    return [handValue, intHandValue]
  end

  def getPayouts(val)
    payTable =
    [
      ["Credits", "Royal Flush", "Straight Flush", "Four of a Kind", "Full House",
        "Flush", "Straight", "Three of a Kind", "Two Pair", "Jacks or Better"],
        [1, 250, 50, 25, 9, 6, 4, 3, 2, 1],
        [2, 500, 100, 50, 18, 12, 8, 6, 4, 2],
        [3, 750, 150, 75, 27, 18, 12, 9, 6, 3],
        [4, 1000, 200, 100, 36, 24, 16, 12, 8, 4],
        [5, 4000, 250, 125, 45, 30, 20, 15, 10, 5]
    ]

    val = 9 - val + 1
    bet = params[:compute][:bet]
    pay = 0
    
    if val > 0
      pay = payTable[bet][val]
    end

    return pay
  end
end
