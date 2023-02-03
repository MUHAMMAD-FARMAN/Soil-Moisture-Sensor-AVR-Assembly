.macro sensor_check_Value
	
; I/O Pins Configuration
SBI DDRB,4 ; Set PB4 pin for Output to LED
CBI PORTB,4 ; LED OFF
; ADC Configuration
LDI r16,0b11000111 ; [ADEN ADSC ADATE ADIF ADIE ADIE ADPS2 ADPS1 ADPS0]
STS ADCSRA,r16
LDI r16,0b01100000 ; [REFS1 REFS0 ADLAR – MUX3 MUX2 MUX1 MUX0]
STS ADMUX,r16 ; Select ADC0 (PC0) pin
SBI PORTC,PC0 ; Enable Pull-up Resistor
loop:
LDS r16,ADCSRA ; Start Analog to Digital Conversion
ORI r16,(1<<ADSC)
STS ADCSRA,r16
wait:
LDS r16,ADCSRA ; wait for conversion to complete
sbrc r16,ADSC
rjmp wait
LDS r16,ADCL ; Must Read ADCL before ADCH
LDS r17,ADCH
delay 100 ; delay 100ms
cpi r17,100 ; compare LDR reading with our desired threshold
brsh LED_ON ; jump if same or higher (r17 >= 200)
CBI PORTB,4 ; LED OFF
rjmp loop
LED_ON:
SBI PORTB,4 ; LED ON
rjmp loop


	
.endmacro