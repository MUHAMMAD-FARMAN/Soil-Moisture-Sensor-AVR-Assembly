.include "m328pdef.inc"
.include "delay.inc"
.include "1602_LCD.inc"
.include "div.inc"

.def A = r16
.def AH = r17

.cseg
.org 0x00



; Setting pins to Output for LCD
sbi DDRD,PD0 ; D0 pin of LCD
sbi DDRD,PD1 ; D1
sbi DDRD,PD2 ; D2
sbi DDRD,PD3 ; D3
sbi DDRD,PD4 ; D4
sbi DDRD,PD5 ; D5
sbi DDRD,PD6 ; D6
sbi DDRD,PD7 ; D7
SBI DDRB,4   ; 12 , LED



;Setting LCD Mode selection pins
sbi DDRB,PB0 ; RS
sbi DDRB,PB1 ; E pin of LCD

;Setting LCD Backlight pin
sbi DDRB,PB5 ; BLA pin of LCD
sbi PORTB,PB5 ; Backlight ON

; LCD Init 
LCD_send_a_command 0x01 ; sending all clear command
LCD_send_a_command 0x38 ; set LCD mode to 16*2 line LCD
LCD_send_a_command 0x0C ; screen ON





;Sensors Things

; ADC Configuration
LDI A,0b11000111 ; [ADEN ADSC ADATE ADIF ADIE ADIE ADPS2 ADPS1 ADPS0]
STS ADCSRA,A
LDI A,0b01100000 ; [REFS1 REFS0 ADLAR – MUX3 MUX2 MUX1 MUX0]
STS ADMUX,A ; Select ADC0 (PC0) pin
SBI PORTC,PC0 ; Enable Pull-up Resistor

loop:	

	LDS A,ADCSRA ; Start Analog to Digital Conversion
	ORI A,(1<<ADSC)
	STS ADCSRA,A

wait:
	LDS A,ADCSRA ; wait for conversion to complete
	sbrc A,ADSC
	rjmp wait

	LDS A,ADCL ; Must Read ADCL before ADCH
	LDS AH,ADCH
	
	

	MOV A, AH
	mov r29,AH
	ldi AH,10
	ldi r30, 48




	ldi r31,3 ;To execute loop 3 times , working as loop counter
	


label1:
	div
	add r15,r30
	push r15
	dec r31
	brne label1

	

	// Display "Moisture : [ " on LCD
	LCD_send_a_character 0x4D ;M
	LCD_send_a_character 0x4F ;O
	LCD_send_a_character 0x49 ;I
	LCD_send_a_character 0x53 ;S
	LCD_send_a_character 0x54 ;T
	LCD_send_a_character 0x55 ;U
	LCD_send_a_character 0x52 ;R
	LCD_send_a_character 0x45 ;E

	LCD_send_a_character 0x3A ;:
	LCD_send_a_character 0x5B ;[



	ldi r31,3  ;To execute loop 3 times , working as loop counter
	;loop to diplay value on LCD
label3:
		pop r15
		LCD_send_a_register r15
		dec r31
	brne label3
		
	LCD_send_a_character 0x5D ;]

	delay 1000

	

	LCD_send_a_command 0x01 ; clear screen on LCD

	
	;Comparison with threshold value

	cpi r29,160  ; compare LDR reading with our desired threshold 200
	brlo LED_OFF ; jump if less (r29 < 200)
	brsh LED_ON ; jump if same or higher (r29 >= 200)


	
	


rjmp loop




LED_OFF:
	CBI PORTB,4

rjmp loop

LED_ON:
	SBI PORTB,4

rjmp loop
















; 970 in dry soil
; 320 in wet soil





