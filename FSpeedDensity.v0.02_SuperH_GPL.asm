finish_maf:
mov.w	(rpm), r1
mov.w	(dmap), r2
fmov.s	@r1, fr15			! fr15 = rpm
mov.w	(map), r1
fmov.s	@r2, fr14			! fr14 = delta MAP
mova	(EngDisp), r0		
fmov.s 	@r1, fr13			! fr13 = MAP
mov.w	(airtemp), r1
fmov.s	@r0, fr12			! fr12 = engine displacement
mova	(c2k), r0
fmov.s	@r1, fr11			! fr11 = airtemp in celsius
fmov.s	@r0, fr10
mova	(const_sd), r0
fadd	fr10, fr11			! fr11 = airtemp in kelvin
fmov.s	@r0, fr10			! fr10 = speed density constant (k), see spreadsheet
fmul	fr13, fr12			! map * eng displacement
fmul	fr15, fr12			! (map * eng displacement) * rpm
fmul	fr10, fr12			! (map * eng displacement * rpm) * constant
fdiv	fr11, fr12			! raw airflow
mov.l	(pull3d), r9			! @r9 = pull3d
mov.w   (sd_rawflow), r8
mova	(dyndef),r0
mov	r0, r4
jsr 	@r9				! pull dyn map 
fmov	fr14, fr4			! set fr4 map lookup to delta map
fmov 	fr0, fr11			! store dyn comp in fr11
mova	(VEdef), r0			! set r0 = VE map definition address
mov	r0, r4				! set r4 = VE map definition address
fmov	fr13, fr4			! set fr4 = MAP for map pull
jsr	@r9				! pull3d (retrieves VE value from VE 3D map)
fmov	fr15, fr5			! set fr5 = rpm for map pull
mov.w	(ve), r0
mov.l	(maf_out), r1
fmov.s	fr0, @r0			! store VE @ FFFFC400
fmov.s	fr12, @r8			! store raw airflow @ FFFFC404
fmul	fr0, fr12
fmul	fr11, fr12			! calculate in MAP dynamics map
fmov.s	fr12, @r1			! store final SD calculated airflow in place of MAF

lds.l   @r15+, pr
rts
mov.l   @r15+, r14

map:
.word 0xA4E0		! manifold absolute pressure, 32bit float, mmHG

.align 2

maf_ad:
.long 0xFFFF9022	! MAF A/D value (multipled by 38A00000 = volts)

maf_adconv:
.long 0x38A00000	! MAF voltage (16bit value) to floating point (volts) multiplier

maf_def:
.long 0x5594C		! MAF scaling table definition reference 

pull2d:
.long 0x208C		! location of pull_2d subroutine 

maf_out:
.long 0xFFFF90F4	! Location to store output airflow Grams/Sec, 32bit float 

maf_diag:
.long 0xFFFF90F8	! Byte for storing MAF over/under volt diagnostic (#0 ok, #1 overvolt, #2 undervolt) 

maf_maxvolt:
.long 0x614FE		! 16bit value direct compare to A/D value for MAF overvolt diag 

maf_minvolt:
.long 0x61500		! 16bit value direct compare to A/D value for MAF undervolt diag 

rpm:
.word 0xA78C		! engine RPM, 32bit float

dmap:
.word 0xA4D4		! delta MAP

ct:
.word 0xA5DC		! coolant temp, 32bit float, degrees celsius

airtemp:
.word 0xA5E8		! airtemp (should be manifold airtemp, but IAT will work for now) 

ve:
.word 0xC400		! free memory spot to store ve (32bit float)

sd_rawflow:
.word 0xC404		! free memory spot to store intermediate raw airflow (32bit float)

old_airflow:
.word 0xC408		! free memory spot to store SD calculated airflow (32bit float)

.align 2

const_sd:		
.float 0.003871098	! constant needed to wrap up other conversion constants for Ideal Gas Law to ECU units of measure 
			! saves a lot of cycles, see spreadsheet for proof 
			! g/s = (Liter*mmHG*RPM / (Celsius+273) * k * VE 
			! then multiply by any other compensations desired 

c2k:
.float 273.15		! number to add to celsius to get kelvin (required for ideal gas law)

EngDisp:
.float 2.457		! engine displacement (2.457 liters) 

pull3d:
.long 0x2100		! pull3dmap subroutine location in base code

! ******************** MAPS BELOW ********************

VEdef:			! volumetric efficiency map, manifold pressure col, rpm row
.word 13		! 12 columns
.word 18		! 18 rows
.long VEcol
.long VErow
.long VEdata
.long 0x8000000		! 16bit data
.float 4.57763672e-5	! gradient for 16bit to float conv
			! 1.5/32768  (0-1.50 range, 16bit precision)
.float 0		! offset for 16bit to float conv (+ 0)

VEcol:
.float 165,285,385,500,625,725,875,1025,1250,1400,1600,1800,2000

VErow:
.float 800,1200,1600,2000,2400,2800,3200,3600,4000,4400,4800,5200,5600,6000,6400,6800,7200,7600

VEdata:
.word 7150,7449,9958,10351,10665,10794,10943,11089,11177,11242,11307,11383,11383
.word 7398,7646,9694,10132,10499,10716,10956,11076,11190,11255,11320,11396,11396
.word 8081,8447,9658,10002,10486,10716,10813,10959,11207,11272,11346,11422,11422
.word 8456,8796,9659,10001,10497,10742,10853,10998,11229,11301,11385,11474,11474
.word 8627,8928,9659,10042,10499,10768,10917,11037,11281,11371,11474,11578,11578
.word 8749,9024,9676,10121,10512,10795,10995,11186,11468,11668,11864,12058,12058
.word 8854,9128,9793,10224,10537,10848,11152,11475,11805,12323,12580,12710,12710
.word 9073,9334,9946,10365,10653,10986,11398,11864,12388,12983,13176,13240,13240
.word 9383,9620,10233,10738,11191,11716,12322,12721,13043,13291,13410,13501,13501
.word 9576,9821,10422,10978,11481,11999,12439,12800,13095,13305,13410,13501,13501
.word 9538,9777,10396,10953,11441,11968,12369,12749,13008,13199,13305,13370,13370
.word 9488,9736,10316,10884,11359,11860,12261,12607,12875,13047,13099,13139,13139
.word 9428,9668,10238,10789,11265,11740,12115,12435,12677,12815,12854,12842,12842
.word 9374,9593,10152,10682,11157,11606,11956,12220,12414,12517,12531,12454,12454
.word 9308,9528,10061,10572,11022,11420,11733,11936,12090,12130,12080,11951,11951
.word 9242,9464,9972,10452,10853,11215,11477,11630,11706,11679,11564,11435,11435
.word 9166,9375,9856,10312,10653,10966,11149,11240,11227,11151,11035,10906,10906
.word 9078,9298,9741,10160,10461,10684,10814,10817,10752,10659,10530,10402,10402


dyndef:			! dynamics table (enrich/impoverish fuel on Delta MAP)
.word 7			! 7 elements 
.word 0x800		! 16 bit data
.long dyncol		
.long dyndata		
.long 0x8000000		! 16bit data
.float 6.1037e-5	! 2.00/32767  (0-2.00 range, 16bit precision)
.float 0		! + 0

dyncol:
.float -150,-60,20,0,20,60,150

dyndata:
.word 11000,14000,16300,16384,16500,18000,20000