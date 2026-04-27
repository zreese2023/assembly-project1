INCLUDE irvine32.inc
SetConsoleOutputCP PROTO STDCALL, codePage:DWORD

.data
; cards for player and dealer
; Note: usually in blackjack, the player
; and the dealer will not have more than 5 cards each
pCardArray DWORD 0,0,0,0,0
dCardArray DWORD 0,0,0,0,0
cardArray DWORD 13 DUP (1,2,3,4,5,6,7,8,9,10,10,10,10) ; card values

; suits for player and dealer
pSuitArray DWORD 0,0,0,0,0
dSuitArray DWORD 0,0,0,0,0

playerWallet DWORD 500 ; start with $500
bet DWORD 0 ; this turns bet
wallet BYTE "Your wallet: $",0
betPrint BYTE "Your bet: $",0
invalidBet BYTE "Try again, bet must be between 0 and your max money: $",0
outOfMoney BYTE "Out of money, you lose!",0

; player and dealer scores
playerCount DWORD 0
playerScore DWORD 0
dealerCount DWORD 0
dealerScore DWORD 0

; blackjack messages
playerBJ BYTE "Blackjack, you win!",0
pushBJ BYTE "You and dealer have a blackjack, push!",0

; hidden string, so you can only see dealers up card
hidden BYTE ?,0

; track if player or dealer has an ace
playerAce DWORD 0
dealerAce DWORD 0
aceMSG BYTE 'A',0

doubleDown DWORD 0 ; double down flag
doubleMessage BYTE " (doubled down)",0
noDouble BYTE "Cannot double down",0

; string messages to help with output and gameplay
playerTurnMessage BYTE "Your hand: ",0 ; player turn
playerActionMSG BYTE "Hit or stand (h/s)?: ",0 ; player can hit or stand
playerActionDouble BYTE "Hit, stand, or double down (h/s/d)?: ",0
dealerTurnMessage BYTE "Dealer's hand:",0 ; dealers turn
winMessage BYTE "You win!",0 ; player wins
loseMessage BYTE "Dealer wins :(",0 ; player loses, dealer wins
pushMessage BYTE "Push (draw)",0 ; push (draw)
playAgainMessage BYTE "Play again (y/n)?: ",0 ; message to prompt to play again
invalidMessage BYTE "Invalid key: try again", 0 ; if player enters an invalid key
goodbye BYTE "Goodbye!", 0 ; exit game message

.code

Draw PROC
	; get a random card procedure (1-13)
	mov eax,13 ; 13 possible card values
	call RandomRange ; irvine32 procedure, puts a random integer into eax from range 0 to eax-1
	; NOTE: RandomRange was not taught in class, so i consulted the internet/AI for the documentation
	; on how to get random numbers in MASM with the irvine library.
	inc eax ; 0 isnt a possible value, so add 1 to eax so we have values 1-13
	mov ecx,eax ; move result to ecx use in determining value (if ace or face card)
	ret
Draw ENDP

DrawSuit PROC
	; gets a random suit for the card
	; 0: spades
	; 1: clubs
	; 2: hearts
	; 3: diamonds
	mov eax,4
	call RandomRange
	ret
DrawSuit ENDP

ShowWallet PROC ; procedure to print the players total money
	mov edx,OFFSET wallet
	call WriteString
	mov eax,playerWallet
	call WriteDec
	call Crlf
	ret
ShowWallet ENDP

PlayerBet PROC
L1:
	call ShowWallet ; print wallet
	mov edx, OFFSET betPrint
	call WriteString
	call ReadDec ; get player bet
	call Crlf

	; check validity of bet, jump to invalid if invalid
	cmp eax,0
	je invalid
	cmp eax,playerWallet
	jg invalid
	mov bet,eax
	ret
invalid: ; prompt player to re type bet if invalid
	mov edx,OFFSET invalidBet
	call WriteString
	mov eax,playerWallet
	call WriteDec
	call Crlf
	jmp L1
PlayerBet ENDP

WinBet PROC ; pay player even money for winning a bet
	; if the player wins they are paid 2:1 for their bet
	mov eax,playerWallet
	add eax,bet
	mov playerWallet,eax
	ret
WinBet ENDP

LoseBet PROC ; if player loses the hand they lose whatever their wager was
	mov eax,playerWallet
	sub eax,bet
	mov playerWallet,eax
	ret
LoseBet ENDP

BlackjackPay PROC
	; special case for blackjack payout: player blackjack pays 3:2
	mov eax,bet
	mov ebx,3 ; multiply by 3
	mul ebx
	mov ebx,2 ; div by 2
	div ebx
	add playerWallet,eax
	ret
BlackjackPay ENDP

Value PROC
	; get card value, input is placed in ecx (moved there in Draw proc)
	mov eax,ecx ; get input from ecx from Draw proc
	cmp eax,1 ; if ace card jump to ace label
	je ace
	cmp eax,11 ; if not a face card
	jb standard
	cmp eax,12 ; jump to faceCard label if greater or equal to 12
	jge faceCard
standard: ; regular card
	mov eax,ecx ; move result to eax
	ret ; return eax
faceCard: ; face card
	mov eax,10 ; move 10 (face card value) to eax
	ret ; return eax
ace: ; ace
	mov eax,11 ; move 11 (will update ace logic later) to eax
	ret ; return
Value ENDP

ResetRound PROC ; procedure to reset the player and dealer arrays to 0 for a new round
	mov edi, OFFSET pCardArray ; reset player cards
	mov ecx,5
	mov eax,0
	rep stosd

	mov edi, OFFSET dCardArray ; reset dealer cards
	mov ecx,5
	rep stosd

	; reset suit arrays
    mov edi,OFFSET pSuitArray
    mov ecx,5
    rep stosd
 
    mov edi,OFFSET dSuitArray
    mov ecx,5
    rep stosd

	mov playerCount,0 ; reset count vars
	mov dealerCount,0
	mov playerScore,0 ; reset score vars
	mov dealerScore,0
	mov playerAce,0 ; zero ace flags
	mov dealerAce,0
	mov doubleDown,0
	mov bet,0

	ret
ResetRound ENDP

DrawP PROC
	; Player drawing cards procedure
	call Draw ; get random card value
	mov ecx,eax
	call Value ; get card value
	cmp eax,11 ; if ace drawn
	jne noAce ; if not an ace jump
	mov playerAce,1 ; otherwise set ace flag
noAce: ; not an ace
    add playerScore,eax ; add drawn card to score
    cmp playerScore,21 ; check if 21
    jle L1 ; if less than 21
    cmp playerAce,1 ; if ace flag set
    jne L1 ; jump if ace flag not set
    sub playerScore,10 ; subtract 10 from player score (ace treated as 1 instead of 11 for score)
    mov playerAce,0 ; reset ace flag
L1:
    mov ebx,playerCount ; index for player card array
    mov pCardArray[ebx*4],eax ; put card into array
	push ebx
	call DrawSuit ; get the suit for the card into player suit array
	pop ebx
	mov pSuitArray[ebx*4],eax
    inc playerCount ; move to next index
    ret
DrawP ENDP

DrawD PROC
	; Draw dealer cards procedure, same logic as DrawP proc
	call Draw ; get random number
	mov ecx,eax ; move ecx to eax for Value proc
	call Value ; get card value
	cmp eax,11 ; if ace
    jne noAce ; jump if not ace
    mov dealerAce,1 ; set dealer ace flag if dealer gets an ace
noAce: ; uses same logic as player drawing an ace but modifies dealer variables
	   ; therefore refer to DrawP for documentation of logic.
    add dealerScore,eax
    cmp dealerScore,21
    jle L1
    cmp dealerAce,1
    jne L1
    sub dealerScore,10
    mov dealerAce,0
L1:
    mov ebx,dealerCount
    mov dCardArray[ebx*4],eax
	push ebx
	call DrawSuit
	pop ebx
	mov dSuitArray[ebx*4],eax
    inc dealerCount
    ret
DrawD ENDP

PrintSuit PROC
	; prints the appropriate ASCII character for the corresponding suit
	; 0=spade
	; 1=club
	; 2=hearts
	; 3=diamonds
	push eax ; must preserve eax because card value will be in eax
	push ecx
	cmp ebx,2
	jge RedSuit ; 2-3 are red suits, 0-1 are black (printed as white) suits
	mov eax,(black*16)+white
	call SetTextColor
	jmp Print
RedSuit:
	mov eax,(black*16)+red
	call SetTextColor
Print:
	cmp ebx,0
	je Spade
	cmp ebx,1
	je Club
	cmp ebx,2
	je Heart
	mov al,4 ; ASCII for diamond
	jmp Write
Spade:
	mov al,6 ; ASCII for spades
	jmp Write
Club:
	mov al,5 ; ASCII for clubs
	jmp Write
Heart:
	mov al,3 ; ASCII for hearts
	jmp Write
Write:
	call WriteChar
	mov eax,white ; reset text color
	call SetTextColor
	pop ecx
	pop eax
	ret
PrintSuit ENDP

PrintCard PROC 
	; procedure to do the ace logic instead of having it in both of the player and dealer print procs
	; prints cards in the following format: [ (number) (suit) ] in the corresponding color
	push ecx
	push eax
	mov al,'['
	call WriteChar
	pop eax
	cmp eax,11
	je Ace ; jump if ace
	cmp eax,1
	je Ace
	call WriteDec
	jmp Suit
Ace:
	mov edx,OFFSET aceMSG
	call WriteString
Suit:
	mov al,' '
	call WriteChar
	call PrintSuit
	mov al,']'
	call WriteChar
	mov al,' '
	call WriteChar
	pop ecx
	ret
PrintCard ENDP

ShowHiddenCard PROC
	; only show dealers upcard and not both
	mov edx,OFFSET dealerTurnMessage
	call WriteString
	call Crlf
	mov eax,dCardArray[0] ; print first card as usual
	mov ebx,dSuitArray[0]
	call PrintCard ; use new PrintCard proc to handle ace logic
	mov edx,OFFSET hidden
	call WriteString
	call Crlf
	ret
ShowHiddenCard ENDP

ShowPCards PROC
	; show player cards procedure
	mov edx, OFFSET playerTurnMessage ; load players turn message address to edx for WriteString
	call WriteString ; print players turn message
	call Crlf ; new line
	mov ecx,playerCount ; load number of player cards to ecx for loop
	mov esi,0
L1: ; loop to print players cards
	mov eax,pCardArray[esi*4] ; get player card into eax
	mov ebx,pSuitArray[esi*4]
	call PrintCard ; use PrintCard for ace logic
	inc esi
	Loop L1
	call Crlf ; new line
	mov eax,playerScore ; print the current total
	call WriteDec
	call Crlf
	; code to print the players wallet and their bet
	mov edx,OFFSET wallet
	call WriteString
	mov eax,playerWallet
	call WriteDec
	mov al,' '
	call WriteChar
	mov al,'|'
	call WriteChar
	mov al,' '
	call WriteChar
	mov edx,OFFSET betPrint
	call WriteString
	mov eax,bet
	call WriteDec
	cmp doubleDown,1
	jne NoDoubleDown
	mov edx,OFFSET doubleMessage
	call WriteString
NoDoubleDown:
	call Crlf
	ret ; return
ShowPCards ENDP

ShowDCards PROC
	; show dealer cards procedure
	mov edx, OFFSET dealerTurnMessage ; address of dealer turn msg into edx
	call WriteString
	call Crlf ; new line
	mov ecx,dealerCount ; load player cards to ecx
	mov esi,0 ; track index of array
L1: ; loop to print dealer cards
	mov eax,dCardArray[esi*4] ; dealer card array
	mov ebx,dSuitArray[esi*4]
	Call PrintCard ; use new PrintCard procedure
	inc esi
	loop L1
	call Crlf ; new line
	mov eax,dealerScore
	call WriteDec ; print dealer score
	call Crlf
	ret
ShowDCards ENDP

PTurn PROC
	; main procedure for player turn
L1:
	call Clrscr
	call ShowPCards ; print player cards
	call Crlf ; new line
	call ShowHiddenCard ; show dealers up card ONLY, not the second card
	call Crlf
	; see if player can double down
	cmp playerCount,2
	jne CantDouble
	mov eax,bet
	add eax,bet
	cmp eax,playerWallet
	jg CantDouble
	mov edx,OFFSET playerActionDouble
	jmp Prompt
CantDouble: ; different prompt if player cant double down
	mov edx,OFFSET playerActionMSG
Prompt:
	call WriteString
	call ReadChar
	cmp al,'h' ; hit
	je hit
	cmp al,'H'
	je hit
	cmp al,'s' ; stand
	je stand
	cmp al,'S'
	je stand
	cmp al,'d' ; double down
	je tryDD
	cmp al,'D'
	je tryDD
	jmp L1
hit: ; if player hits
	call DrawP ; player draws card
	cmp playerScore,21 ; if greater than 21 player loses
	jg bust
	jmp L1
stand: ; proc ends if player stands, no more actions
	mov eax,0
	ret
tryDD: ; player tries to double down, check if they can
	cmp playerCount,2 ; ensure player has 2 cards
	jne L1
	mov eax,bet ; ensure player has enough money
	add eax,bet
	cmp eax,playerWallet
	jg noDD
	; double the wager
	mov eax,bet
	add bet,eax
	mov doubleDown,1

	call DrawP ; draw 1 more card and go from there
	cmp playerScore,21
	jg bust
	mov eax,0
	ret
noDD:
	mov edx,OFFSET noDouble
	call WriteString
	call Crlf
	jmp L1
bust: ; if player gets more than 21
	call LoseBet ; subtract money if player loses
	call Clrscr
	call ShowPCards
	call Crlf
	call ShowDCards
	mov edx,OFFSET loseMessage
	call WriteString ; print loss message
	call Crlf ; new line
	call ShowWallet ; show players new amount of money
	call Crlf
	call ReadKey
	mov eax,1
	ret ; exit program
PTurn ENDP

DTurn PROC
; procedure for dealer turn
; dealer will stand on soft 17
L1: ; main loop
	cmp dealerScore,17 ; stands on 17
	jge stand
	call DrawD ; if less than 17 dealer hits
	jmp L1 ; loop
stand:
	cmp dealerScore,21 ; if dealer over 21, player wins
	jg bust
	mov eax,0
	ret
bust: ; dealer over 21
	call WinBet ; player wins wager on dealer bust
	call Clrscr
	call ShowPCards
	call Crlf
	call ShowDCards
	call Crlf
	mov edx,OFFSET winMessage ; print win message
	call WriteString
	call Crlf
	call ShowWallet
	call Crlf
	call ReadKey
	mov eax,1
	ret
DTurn ENDP

CheckBJ PROC
	; check if player doesnt have blackjack and jump to correct label
	cmp playerScore,21
	jne NoPlayerBJ
	cmp playerCount,2
	jne NoPlayerBJ

	; if player has blackjack, check dealer too for push
	cmp dealerScore,21
	jne NoDealerBJ
	cmp dealerCount,2
	jne NoDealerBJ

	; if player and dealer have blackjack it is a push
	call Clrscr
	call ShowPCards
	call Crlf
	call ShowDCards
	mov edx,OFFSET pushBJ
	call WriteString
	call Crlf
	call ShowWallet
	call Crlf
	call ReadKey
	mov eax,1
	ret
NoDealerBJ:
	call BlackjackPay
	call Clrscr
	call ShowPCards
	call Crlf
	call ShowDCards
	call Crlf
	mov edx,OFFSET playerBJ
	call WriteString
	call Crlf
	call ShowWallet
	call Crlf
	call ReadKey
	mov eax,1
	ret
NoPlayerBJ:
	mov eax,0
	ret
CheckBJ ENDP

Score PROC
; determine winner: player or dealer
	mov eax,playerScore ; put player score into register
	mov ebx,dealerScore ; dealer score in another register
	cmp eax,ebx ; compare
	jg win ; if player beats dealer
	jl lose ; if player has less than dealer
	je tie ; if tie game
win: ; print win message and exit
	call WinBet
	mov edx,OFFSET winMessage
	call WriteString
	call Crlf
	call ShowWallet
	call Crlf
	call ReadKey
	ret
lose: ; print loss message and exit
	call LoseBet
	mov edx,OFFSET loseMessage
	call WriteString
	call Crlf
	call ShowWallet
	call Crlf
	call ReadKey
	ret
tie: ; print tie message and exit
	mov edx,OFFSET pushMessage
	call WriteString
	call Crlf
	call ShowWallet
	call Crlf
	call ReadKey
	ret
Score ENDP

PromptPlayAgain PROC ; ask player to play again
	call Crlf
	mov edx, OFFSET playAgainMessage ; prompt player if they want to play again
	call WriteString
	call ReadChar
	call Crlf
	cmp al, 'y'
	je yes ; if yes jump to play again
	cmp al, 'Y'
	je yes
	cmp al, 'n'
	je no ; if no jump to quit
	cmp al, 'N'
	je no
	mov edx, OFFSET invalidMessage
	call WriteString
	jmp PromptPlayAgain
yes: ; reset vars and start again
	mov eax,1
	ret
no: ; player chooses to quit, exit program
	mov eax,0
    ret
PromptPlayAgain ENDP

main PROC
	INVOKE SetConsoleOutputCP,437
	call Randomize ; irvine32 procedure to generate a new seed for a random number generator
	; the invoke above I taught myself with the internet outside of class
	; the program wouldnt print the correct ASCII characters, so this sets the modes


Start:
	cmp playerWallet,0 ; ensure player has money
	jg HasMoney
	call Clrscr
	mov edx,OFFSET outOfMoney
	call WriteString
	call Crlf
	call ReadKey
	jmp quit

HasMoney:
	call Clrscr
	call PlayerBet
	call DrawP ; get first 2 player cards
	call DrawP
	call DrawD ; get first 2 dealer cards
	call DrawD

	; check for blackjack
	call CheckBJ
	cmp eax,1
	je Next

	call PTurn ; player turn
	cmp eax,1
	je Next
	call DTurn ; dealer turn
	cmp eax,1
	je Next
	call Clrscr ; clear screen
	call ShowPCards
	call ShowDCards ; show dealer cards using procedure
	call Score ; determine if player or dealer won

Next: ; after game, prompt player to play again
	call PromptPlayAgain
	cmp eax,1
	je PlayAgain
	jmp quit
PlayAgain: ; player chooses to play again
	call ResetRound
	jmp Start
quit: ; player chooses to quit
	call Clrscr
	mov edx, OFFSET goodbye
	call WriteString
	call Crlf
	INVOKE ExitProcess,0
main ENDP
END main