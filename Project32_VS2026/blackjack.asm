INCLUDE irvine32.inc

.data
; cards for player and dealer
; Note: usually in blackjack, the player
; and the dealer will not have more than 5 cards each
pCardArray DWORD 0,0,0,0,0
dCardArray DWORD 0,0,0,0,0
cardArray DWORD 13 DUP (1,2,3,4,5,6,7,8,9,10,10,10,10) ; card values

; player and dealer scores
playerCount DWORD 0
playerScore DWORD 0
dealerCount DWORD 0
dealerScore DWORD 0

; hidden string, so you can only see dealers up card
hidden BYTE ?,0

; track if player or dealer has an ace
playerAce DWORD 0
dealerAce DWORD 0
aceMSG BYTE 'A',0

; string messages to help with output and gameplay
playerTurnMessage BYTE "Your hand: ",0 ; player turn
playerActionMSG BYTE "Hit or stand (h/s)?: ",0 ; player can hit or stand
dealerTurnMessage BYTE "Dealer's hand:",0 ; dealers turn
winMessage BYTE "You win!",0 ; player wins
loseMessage BYTE "Dealer wins :(",0 ; player loses, dealer wins
pushMessage BYTE "Push (draw)",0 ; push (draw)

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
    inc dealerCount
    ret
DrawD ENDP

ShowHiddenCard PROC
	; only show dealers upcard and not both
	mov edx,OFFSET dealerTurnMessage
	call WriteString
	call Crlf
	mov eax,dCardArray[0] ; print first card as usual
	push ecx
	; same logic to check for an ace to print properly
	cmp eax,11
	je ace
	cmp eax,1
	je ace
	call WriteDec
	jmp postPrint
ace: ; if card is ae
	mov edx,OFFSET aceMSG
	call WriteString
postPrint:
	pop ecx
	mov al,' '
	call WriteChar ; print a space
	mov edx,OFFSET hidden ; dont print second dealer card for game purposes, print blank string
	call WriteString
	call Crlf ; new line
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
	push ecx
	cmp eax,11
	je ace
	cmp eax,1
	je ace
	call WriteDec ; print playerc ard
	jmp postPrint
ace:
	mov edx,OFFSET aceMSG
	call WriteString
postPrint:
	pop ecx
	mov al,' ' ; print a space
	call WriteChar
	inc esi ; move to next element in array
	loop L1 ; loop

	call Crlf ; new line
	mov eax,playerScore ; print the current total
	call WriteDec
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
	push ecx
	cmp eax,11
	je ace
	cmp eax,1
	je ace
	call WriteDec ; print card
	jmp postPrint
ace:
	mov edx,OFFSET aceMSG
	call WriteString
postPrint:
	pop ecx
	mov al,' ' ; print a space
	call WriteChar
	inc esi ; move to next index
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
	mov edx, OFFSET playerActionMSG ; prompt player to hit or stand
	call WriteString ; print
	call ReadChar ; use read char to block program until input received
	call Crlf
	cmp al,'h' ; hit
	je hit
	cmp al,'H'
	je hit
	cmp al,'s' ; stand
	je stand
	cmp al,'S'
	je stand
	jmp L1
hit: ; if player hits
	call DrawP ; player draws card
	cmp playerScore,21 ; if greater than 21 player loses
	jg bust
	jmp L1
stand: ; proc ends if player stands, no more actions
	ret
bust: ; if player gets more than 21
	call Clrscr
	call ShowDCards
	mov edx,OFFSET loseMessage
	call WriteString ; print loss message
	call Crlf ; new line
	call ReadKey
	exit ; exit program
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
	ret
bust: ; dealer over 21
	call Clrscr
	mov edx,OFFSET winMessage ; print win message
	call WriteString
	call Crlf
	call ReadKey
	exit
DTurn ENDP

Score PROC
; determine winner: player or dealer
	mov eax,playerScore ; put player score into register
	mov ebx,dealerScore ; dealer score in another register
	cmp eax,ebx ; compare
	jg win ; if player beats dealer
	jl lose ; if player has less than dealer
	je tie ; if tie game
win: ; print win message and exit
	mov edx,OFFSET winMessage
	call WriteString
	call Crlf
	call ReadKey
	exit
lose: ; print loss message and exit
	mov edx,OFFSET loseMessage
	call WriteString
	call Crlf
	call ReadKey
	exit
tie: ; print tie message and exit
	mov edx,OFFSET pushMessage
	call WriteString
	call Crlf
	call ReadKey
	exit
Score ENDP

main PROC
	call Randomize ; irvine32 procedure to generate a new seed for a random number generator
	call DrawP ; get first 2 player cards
	call DrawP
	call DrawD ; get first 2 dealer cards
	call DrawD
	call PTurn ; player turn
	call DTurn ; dealer turn
	call Clrscr ; clear screen
	call ShowDCards ; show dealer cards using procedure
	call Score ; determine if player or dealer won
	INVOKE ExitProcess,0
main ENDP
END main