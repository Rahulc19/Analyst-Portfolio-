# rock paper scissors game with a score counter
import random

player_win_counter = 0  # intializing player and computer win counters
computer_win_counter = 0

computer_answers = ['Rock', 'Paper', 'Scissors'] #List for random selection

# To loop through the choices of user until 3 wins are completed by computer or user.
while player_win_counter < 3 and computer_win_counter < 3:
    player_choice = input("Let's play Rock, Paper, Scissors. This is a best of 3. Choose one: ")
    if player_choice.lower() == 'rock':
        computer_choice = random.choice(computer_answers)
        print(f'Computer chose {computer_choice}')
        if computer_choice.lower() == "paper":
            computer_win_counter += 1
            print(f"""The computer covers your {player_choice} ! The score is:
                  You: {player_win_counter}
                  Computer: {computer_win_counter}""")
        elif computer_choice.lower() == 'rock':
            print("It's a tie! Try again.")
        else:
            player_win_counter += 1
            print(f"""You smash the computers {computer_choice}! The score is:
                  You: {player_win_counter}
                  Computer: {computer_win_counter}""")
    elif player_choice.lower() == 'paper':
        computer_choice = random.choice(computer_answers)
        print(f'Computer chose {computer_choice}')
        if computer_choice.lower() == 'scissors':
            computer_win_counter += 1
            print(f"""The computer cuts your {player_choice}! The score is:
                  You: {player_win_counter}
                  Computer: {computer_win_counter}""")
        elif computer_choice.lower() == player_choice.lower():
            print("It's a tie! Try again.")
        else:
            player_win_counter += 1
            print(f"""You cover the computers {computer_choice} The score is:
                  You: {player_win_counter}
                  Computer: {computer_win_counter}""")
    elif player_choice.lower() == 'scissors':
        computer_choice = random.choice(computer_answers)
        print(f'Computer chose {computer_choice}')
        if computer_choice.lower() == "rock":
            computer_win_counter += 1
            print(f"""The computer smashes your {player_choice}! The score is:
                  You: {player_win_counter}
                  Computer: {computer_win_counter}""")
        elif computer_choice.lower() == player_choice.lower():
            print("It's a tie! Try again.")
        else:
            player_win_counter += 1
            print(f"""You cut the computers {computer_choice}! The score is:
                  You: {player_win_counter}
                  Computer: {computer_win_counter}""")
    else:
        print("I did not understand that, please try again") #To account for mispelled inputs.

if player_win_counter > computer_win_counter:
    print('You won the best of three! You were lucky I guess...')
else:
    print("""
    You lost to a computer. Wow...""")


