EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Apico Shield"
Date "2021-10-27"
Rev "1.0"
Comp "Olivier Boesch (Lycée Saint Exupéry - Marseille)"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Arduino_lib:Arduino_Uno_Shield APICO_UNO1
U 1 1 6175C785
P 5750 3650
F 0 "APICO_UNO1" H 5750 5037 60  0000 C CNN
F 1 "Arduino_Uno_Shield" H 5750 4931 60  0000 C CNN
F 2 "arduino_lib:Arduino_Uno_Shield" H 7550 7400 60  0001 C CNN
F 3 "https://store.arduino.cc/arduino-uno-rev3" H 7550 7400 60  0001 C CNN
	1    5750 3650
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x05_Male b2
U 1 1 6175E4DE
P 8100 3200
F 0 "b2" H 8072 3132 50  0000 R CNN
F 1 "Mass" H 8072 3223 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x05_P2.54mm_Vertical" H 8100 3200 50  0001 C CNN
F 3 "~" H 8100 3200 50  0001 C CNN
	1    8100 3200
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x04_Male C1
U 1 1 6175FCB3
P 3200 3150
F 0 "C1" H 3308 3431 50  0000 C CNN
F 1 "Grove CO2" H 3308 3340 50  0000 C CNN
F 2 "Connector:NS-Tech_Grove_1x04_P2mm_Vertical" H 3200 3150 50  0001 C CNN
F 3 "~" H 3200 3150 50  0001 C CNN
	1    3200 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 3400 7900 3300
$Comp
L Connector:Conn_01x09_Male b1
U 1 1 61765E56
P 8200 4100
F 0 "b1" H 8172 4032 50  0000 R CNN
F 1 "Radio rfm9x" H 8172 4123 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x09_P2.54mm_Vertical" H 8200 4100 50  0001 C CNN
F 3 "~" H 8200 4100 50  0001 C CNN
	1    8200 4100
	-1   0    0    1   
$EndComp
Wire Wire Line
	3850 4600 4450 4600
Wire Wire Line
	7900 3400 7900 3700
Wire Wire Line
	7900 3700 8000 3700
Connection ~ 7900 3400
Wire Wire Line
	7900 3700 7900 5150
Wire Wire Line
	7900 5150 3900 5150
Connection ~ 7900 3700
Wire Wire Line
	7900 3000 7800 3000
Wire Wire Line
	7800 3000 7800 3800
Wire Wire Line
	7800 3800 8000 3800
Wire Wire Line
	7800 3800 7800 5050
Wire Wire Line
	7800 5050 3950 5050
Wire Wire Line
	3950 5050 3950 4300
Connection ~ 7800 3800
Wire Wire Line
	3950 4200 4450 4200
Wire Wire Line
	8000 4000 7650 4000
Wire Wire Line
	7650 4000 7650 2700
Wire Wire Line
	7650 2700 7050 2700
Wire Wire Line
	8000 4100 7600 4100
Wire Wire Line
	7600 4100 7600 3700
Wire Wire Line
	7600 3700 7050 3700
Wire Wire Line
	7050 3600 7550 3600
Wire Wire Line
	7550 3600 7550 4200
Wire Wire Line
	7550 4200 8000 4200
Wire Wire Line
	8000 4300 7500 4300
Wire Wire Line
	7500 4300 7500 3500
Wire Wire Line
	7500 3500 7050 3500
Wire Wire Line
	8000 4400 7450 4400
Wire Wire Line
	7450 4400 7450 2800
Wire Wire Line
	7450 2800 7050 2800
Wire Wire Line
	8000 4500 7400 4500
Wire Wire Line
	7400 4500 7400 2600
Wire Wire Line
	7400 2600 7050 2600
Wire Wire Line
	7050 2900 7350 2900
Wire Wire Line
	7350 2900 7350 3100
Wire Wire Line
	7350 3100 7900 3100
Wire Wire Line
	7050 3000 7300 3000
Wire Wire Line
	7300 3000 7300 3200
Wire Wire Line
	7300 3200 7900 3200
Wire Wire Line
	3400 3050 3950 3050
Wire Wire Line
	3950 3050 3950 4200
Connection ~ 3950 4200
Wire Wire Line
	3400 3150 3850 3150
$Comp
L Connector:Conn_01x05_Male C2
U 1 1 6179F92A
P 3250 4400
F 0 "C2" H 3358 4781 50  0000 C CNN
F 1 "Bee Counter" H 3358 4690 50  0000 C CNN
F 2 "TerminalBlock:TerminalBlock_bornier-5_P5.08mm" H 3250 4400 50  0001 C CNN
F 3 "~" H 3250 4400 50  0001 C CNN
	1    3250 4400
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Male C3
U 1 1 617A0961
P 3250 5050
F 0 "C3" H 3358 5231 50  0000 C CNN
F 1 "Power 5V/2A" H 3358 5140 50  0000 C CNN
F 2 "TerminalBlock:TerminalBlock_bornier-2_P5.08mm" H 3250 5050 50  0001 C CNN
F 3 "~" H 3250 5050 50  0001 C CNN
	1    3250 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 4200 3700 4200
Wire Wire Line
	3450 4300 3950 4300
Connection ~ 3950 4300
Wire Wire Line
	3950 4300 3950 4200
Wire Wire Line
	3450 4400 4350 4400
Wire Wire Line
	4350 4400 4350 5250
Wire Wire Line
	4350 5250 7150 5250
Wire Wire Line
	7150 5250 7150 3100
Wire Wire Line
	7150 3100 7050 3100
Wire Wire Line
	7050 3200 7200 3200
Wire Wire Line
	7200 3200 7200 5300
Wire Wire Line
	7200 5300 4250 5300
Wire Wire Line
	4250 5300 4250 4500
Wire Wire Line
	4250 4500 3450 4500
Wire Wire Line
	3450 4600 3450 4750
Wire Wire Line
	3450 4750 4200 4750
Wire Wire Line
	4200 4750 4200 5350
Wire Wire Line
	4200 5350 7250 5350
Wire Wire Line
	7250 5350 7250 3300
Wire Wire Line
	7250 3300 7050 3300
Wire Wire Line
	3400 3250 4000 3250
Wire Wire Line
	4000 3250 4000 3400
Wire Wire Line
	4000 3400 4450 3400
Wire Wire Line
	3400 3350 4150 3350
Wire Wire Line
	4150 3350 4150 3300
Wire Wire Line
	4150 3300 4450 3300
Wire Wire Line
	3450 5050 3950 5050
Connection ~ 3950 5050
Wire Wire Line
	3450 5150 3700 5150
Wire Wire Line
	3700 4200 3700 5150
Wire Wire Line
	3850 3150 3850 4600
Wire Wire Line
	3850 4600 3850 5150
Connection ~ 3850 4600
$Comp
L Connector:Conn_01x02_Male J1
U 1 1 6187056D
P 3800 5750
F 0 "J1" V 3954 5562 50  0000 R CNN
F 1 "Power out" V 3863 5562 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 3800 5750 50  0001 C CNN
F 3 "~" H 3800 5750 50  0001 C CNN
	1    3800 5750
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3800 5550 3800 5300
Wire Wire Line
	3800 5300 3700 5300
Wire Wire Line
	3700 5300 3700 5150
Connection ~ 3700 5150
Wire Wire Line
	3900 5550 3900 5150
Connection ~ 3900 5150
Wire Wire Line
	3900 5150 3850 5150
$EndSCHEMATC
