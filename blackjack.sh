#!/bin/bash

while true; do

# Bets with error checking

while true; do
read -p "What is your initial bet? (please type in a decimal bet) : " input
if [[ "$input" =~ ^[0-9]+(.[0-9]+)?$ ]]; then
bet=$input
break
else
echo "Invalid input. Please enter a valid decimal."
fi
done

# Declarations to match values to names
declare -A stringvalues=( [Ace]=11 [2]=2 [3]=3 [4]=4 [5]=5 [6]=6 [7]=7 [8]=8 [9]=9 [10]=10 [King]=10 [Queen]=10 [Jack]=10 )

# Draws card from an array to simulate a deck
draw() {
    array1=("$1")
    local var1="${array1[0]}"
    echo $var1
}
# Evaluates the array of cards, and subtracts 9 away if an Ace is present, leaving the player to go bust
evaluate_hand() {
	declare -i value
	declare -i card_value
	local -n hand=$1
	naught=()
	value=0
	for card in "${hand[@]}";
	do
		of="_of_"
		val=${card%%${of}*}
		naught+=("$val")
		card_value=${stringvalues[$val]}
		value+=$card_value
	done

	# If score is above 21 and player owns an Ace, then subtract 9 from their score since Ace can either be 1 or 11
    	if [ $value -gt 21 ] && [[ " ${naught[*]} " == *"Ace"* ]]; then
		value=$value-9
	fi
	echo $value
}


# Checks for bust, takes the opponent's name as an input so it can announce a winner, then prompts to restart or quit the game
check_if_bust() {
	declare -i score=$1
	opponent=$2
		if [ $score -gt 21 ];
		then
		printf "\n \n Went bust with score, $score. $opponent wins. \n \n"
			read -p "Enter 'n' to quit or any other key to continue: " input_new_data
				if [ "$input_new_data" != "n" ]; then
					exec ~/TCA2/blackjack.sh
				elif [ "$input_new_data" == "n" ]; then
					exit 0 
				fi
		fi
}



# Checks for the final winner and prints corresponding statements based on outcome
final_winner() {
	declare -i dealer_score=$1
	declare -i player_score=$2

	if [ "$dealer_score" -gt "$player_score" ] && [ "$dealer_score" -le 21 ]; then
		printf "\n \n Dealer won, better luck next time. \n \n"
	elif [ $player_score -gt $dealer_score ] && [ "$player_score" -le 21 ]; then
		printf "\n \n You won! Congratulations! \n \n"
	else
		printf "It's a tie! \n"


	fi

}



# Create deck array based in order
deck=()

suits=( 'Hearts' 'Diamonds' 'Spades' 'Clubs' )
values=( 'Ace' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Jack' 'King' 'Queen' )

for suit in "${suits[@]}";
do
	for value in "${values[@]}";
	do
		deck+=("${value}_of_$suit")
	done

done




# round() contains multiple statements to calculate a round of blackjack
round() {
	
	# Shuffle deck
	shuffled_deck=( $(shuf -e "${deck[@]}") )

	# Start hands
	stand=false
	dealers_hand=()
	players_hand=()

	# Draw cards for the dealer and player and adds to their hands
	dealercard_1=$( draw "${shuffled_deck[@]}" )
	shuffled_deck=("${shuffled_deck[@]:1}")
	dealercard_2=$( draw "${shuffled_deck[@]}" )
	shuffled_deck=("${shuffled_deck[@]:1}")
	player_card_1=$( draw "${shuffled_deck[@]}" )
	shuffled_deck=("${shuffled_deck[@]:1}")
	player_card_2=$( draw "${shuffled_deck[@]}" )
	shuffled_deck=("${shuffled_deck[@]:1}")
	
	dealers_hand+=("$dealercard_1")
	dealers_hand+=("$dealercard_2")
	players_hand+=("$player_card_1")
	players_hand+=("$player_card_2")
	
	# Shows only one of the dealers hand and both cards of the players hand, as well as gives the option to hit or stand
	while ! $stand; do

	printf " \n \ndealers face up card is ${dealers_hand[1]} \n"
	printf "your cards are ${players_hand[*]} \n \n"
	
	player_val=$(evaluate_hand players_hand)

	if [ $player_val -eq 21 ]; then
		printf "you got blackjack !! \n"
		sleep 2
		stand=true
		break
	fi
	
	read -p "do you want to (h)it or (s)tay? : " response
	case $response in
	    H* | h* )
		    printf "\n dealer is drawing you another card... \n"
		    sleep 1
		    new_card=$( draw "${shuffled_deck[@]}" )
		    shuffled_deck=("${shuffled_deck[@]:1}")
		    echo "you are given $new_card"
		    players_hand+=("$new_card")
		    # Check to see if gone bust
		    player_evaluation=$(evaluate_hand players_hand)
		    check_if_bust player_evaluation "dealer"
		    ;;
	    S* | s*) printf "\n dealer's turn! \n"
		    sleep 1
		    stand=true
			;;
	     *) printf "\n Invalid input, please type in either (h) or (s) \n" ;;
	esac

	done
	# In the dealers turn, they flip over their other card and draw based on the rules
	echo "dealers hand is ${dealers_hand[*]}"
	dealer_evaluation=$(evaluate_hand dealers_hand)
	while [ "$dealer_evaluation" -le 17 ]; do
		new_dealercard=$( draw "${shuffled_deck[@]}" )
		shuffled_deck=("${shuffled_deck[@]:1}")
		printf "dealer drew $new_dealercard\n"
		sleep 1
		dealers_hand+=("$new_dealercard")
		dealer_evaluation=$(evaluate_hand dealers_hand)
	done
	sleep 1
	echo "dealers score is now $(evaluate_hand dealers_hand)"
	dealer_evaluation=$(evaluate_hand dealers_hand)
	check_if_bust $(evaluate_hand dealers_hand) "player"
	sleep 1


	# displaying scores
	player_scr=$(evaluate_hand players_hand)
	dealer_scr=$(evaluate_hand dealers_hand)
	echo "player score is $player_scr and dealer score is $dealer_scr"
	final_winner $dealer_scr $player_scr
	echo "Round finished"
	


}



round;

# Restart program
read -p "Enter 'n' to quit or any other key to continue: " input_new_data
if [ "$input_new_data" == "n" ]; then
break
fi
done
