.data 
  mulValue:
    .float 1073741824.0
  input:
    .asciiz "Podaj kat w radianach: "
  result:
    .asciiz "Wynik: \nsin: "
  cos:
    .asciiz "\ncos: "
  ctab:
    .word 0x3243F6A8, 0x1DAC6705, 0x0FADBAFC, 0x07F56EA6, 0x03FEAB76, 0x01FFD55B, 0x00FFFAAA, 0x007FFF55, 0x003FFFEA, 0x001FFFFD, 0x000FFFFF, 0x0007FFFF, 0x0003FFFF, 0x0001FFFF, 0x0000FFFF, 0x00007FFF, 0x00003FFF, 0x00001FFF, 0x00000FFF, 0x000007FF, 0x000003FF, 0x000001FF, 0x000000FF, 0x0000007F, 0x0000003F, 0x0000001F, 0x0000000F, 0x00000008, 0x00000004, 0x00000002, 0x00000001, 0x00000000

.text
.globl main
main:

	li $v0,4 #wypisanie napisu
	la $a0, input
	syscall
read:	
	li $v0,6 # Kod 5 czyli czytanie liczby zmiennoprzecinkowej
	syscall
	
	l.s $f2, mulValue
	mul.s $f0, $f0, $f2
	cvt.w.s $f0, $f0 #f0 = (int)f0
	mfc1 $t3, $f0 #z=theta, $t3 = $f0
cordic:
	li $t0, 0 #i=0
	li $t1, 0x26DD3B6A # x=cordic_1K
	li $t2, 0 #y=0
	#z = $t3 (theta)
	
	calcLoop: #pętla
		#d = z >= 0 ? 0 : -1:
		srl $t4, $t3, 31 #d = z >> 31;
		mul $t4, $t4, -1 #d *= -1
		
		#tx = x - (((y>>k) ^ d) - d)
		srlv $t5, $t2, $t0  #tx = (y>>i)
		xor $t5, $t5, $t4 #tx = tx ^ d
		sub $t5, $t5, $t4 #tx = tx - d
		sub $t5, $t1, $t5 #tx = x - tx
		
		#ty = y + (((x>>k) ^ d) - d);
		srlv $t6, $t1, $t0  #ty = (x>>i)
		xor $t6, $t6, $t4 #ty = ty ^ d
		sub $t6, $t6, $t4 #ty = ty - d
		add $t6, $t2, $t6 #ty = y + ty
		
		move $t1, $t5 #x = tx
		move $t2, $t6 #y =ty
		
		#tz = z - ((cordic_ctab[k] ^ d) - d);
		mul $t7, $t0, 4 #adres co 4 bajty więc trzeba przemnożyć *4
		lw $t7, ctab($t7) #tz = ctab[i]
		xor $t7, $t7, $t4 #(tz ^ d)
		sub $t7, $t7, $t4
		sub $t7, $t3, $t7
		
		move $t3, $t7 #z = tz
		
	add $t0,$t0,1 # i ++
	beq $t0, 32, showResults #i < 32
	j calcLoop
showResults:

	li $v0,4 #wyswietlenie napisu result
	la $a0, result
	syscall
	
	mtc1 $t1, $f0 #przeniesienie do $f0
	cvt.s.w $f0, $f0 #konwesja wotd to single precision
	div.s $f12, $f0, $f2 #podzielenie przez MUL
	
	li $v0, 2 #Wypisywanie liczby zmiennoprzecinkowej z $f12
	syscall
		
	li $v0,4 #Wyświetlenie napisu cos
	la $a0, cos
	syscall
	
	mtc1 $t2, $f0 #przeniesienie do $f0
	cvt.s.w $f0, $f0 #konwesja wotd to single precision
	div.s $f12, $f0, $f2 #podzielenie przez MUL
	
	li $v0, 2 #Wypisywanie liczby zmiennoprzecinkowej z $f12
	syscall
exit:
	li $v0, 10       # exit system call
	syscall
