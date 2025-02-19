.text
.align	2
.global	main

//Bailey Wellen 
//Comp Org - Spring 2019 

/* Registers:
	d8: tpi
	d9: phases
	d10: theta 
	d11: increment

	x19: l
	x20: c
	x21: LINES 
	x22: COLS
	x23: intensity
	x24: levels 
*/
main:
	stp			x30, x19, [sp, -16]!
	stp			x20, x21, [sp, -16]!
	stp			x22, x23, [sp, -16]!
	stp			x24, x25, [sp, -16]!
	stp 		d8,d9, [sp,#-16]!
	stp 		d10,d11, [sp,#-16]!

	//call initscr()
	bl			initscr

	ldr			d0, pi
	//calculate pi * 2 
	fadd		d0, d0, d0
	//tpi is in d8
	fmov		d8, d0
	//set phase to equal 0
	//phase is in d9
	ldr			d9, zero
	//set theta to equal 0
	//theta is in d10
	ldr			d10, zero

	//load up lines 
	adrp		x0, :got:LINES
	ldr			x0, [x0, #:got_lo12:LINES]
	ldr			w0, [x0]
	//store LINES in w21
	mov			w21, w0
	//load up cols 
	adrp		x0, :got:COLS
	ldr			x0,[x0, #:got_lo12:COLS]
	ldr			w0, [x0]
	//store COLS in w22
	mov			w22, w0

	//cast COLS into a double 
	scvtf		d0, w22
	//double increment = tpi / (double) COLS; - store it in d11
	fdiv		d11, d8, d0
	
top:
	bl			erase
	//load up lines 
	adrp		x0, :got:LINES
	ldr			x0, [x0, #:got_lo12:LINES]
	ldr			w0, [x0]
	//store LINES in w21
	mov			w21, w0
	//load up cols 
	adrp		x0, :got:COLS
	ldr			x0,[x0, #:got_lo12:COLS]
	ldr			w0, [x0]
	//store COLS in w22
	mov			w22, w0
	//add increment to phase (phase+= increment)
	fadd		d9, d9, d11
	// l = 0
	mov			w19, wzr

sinner:
	//if (l >= LINES) goto bottom
	cmp			w19, w21
	bge			bottom
	//theta = 0
	ldr			d10, zero
	//c = 0
	mov			w20, wzr

tinner:
	//if (c >= COLS) goto binner;
	cmp			w20, w22
	bge			binner
	//(phase + theta) is now in d0
	fadd		d0, d9, d10
	//(sin (phase + theta)) is returned into d0
	bl			sin

	fmov		d1, 1.0
	//(sin(phase + theta) + 1.0) is in d0 after these 
	fadd		d0, d0, d1
	fmov		d1, 2.0
	fdiv		d0, d0, d1
	//(sin (phase + theta) + 1.0) / 2.0
	fmov		d1, 10.0
	//(sin (phase + theta) + 1.0) / 2.0 * 10.0
	fmul		d0, d0, d1
	//convert intensity value to be an int 
	fcvtzs		w23, d0


	//mvaddch(l, c, levels[intensity])
	mov			w0, w19
	mov			w1, w20
	ldr			x24, =levels 
	//load only 1 byte of levels into w2
	ldrb		w2, [x24, w23, sxtw]
	//call mvadd ch
	bl			mvaddch
	
	//theta+= increment 
	fadd		d10, d10, d11
	//	c++;	
	add			w20, w20, 1
	b			tinner

binner:
	//	l++;
	add			w19, w19, 1
	b			sinner

bottom:
	adrp		x0, :got:stdscr
	ldr			x0, [x0, #:got_lo12:stdscr]
	ldr			x0,[x0]

	mov			x1, xzr
	mov			x2, xzr
	bl			box
	bl			refresh
	b			top


	bl			endwin
  //restore registers 
	ldp 		d10, d11, [sp],#16
	ldp 		d8, d9, [sp],#16
	ldp			x24, x25, [sp], 16
	ldp			x22, x23, [sp], 16
	ldp			x20, x21, [sp], 16
	ldp			x30, x19, [sp], 16
	mov			x0, xzr
	ret


.data 
pi:				.double		3.14159265359
zero:			.double		0.0
levels:			.asciz		" .:-=+*#%@"
.end
