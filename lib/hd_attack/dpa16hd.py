import numpy as np
import math
import redis as Redis
import json
import pyDes

redis = Redis.StrictRedis(host='localhost', port=6379, db=0)
RUN_NAME = "SEC_DES3"

#This is DPA on HD of 16th-15th round over all sboxes

#This is a device we are attacking so we know the key and intermediate round subkeys
key = "6a65786a65786a65".decode("hex")
key16 = "111100001011111000101110010110110010010000101100"

#Split the 16th round intermediate key into 8 subkeys, one for each sbox so we can check our results
roundKey = []
for x in xrange(0,len(key16),6):
	roundKey.append(int(key16[x:x+6],2))

#Load up pyDes with our key, when we compute the HD between the 16th round and 15th round we will use our keyguess
des = pyDes.des(key)

#The 16th round happens between xMin-xMax in the power traces
xMin = 14200
xMax = 14900
diff = xMax - xMin

#For each sbox, for each keyguess, allocate enough space for the power trace information
#One for HD < 2 and one for HD > 2
hdl2 = np.zeros((8,64,diff))
hdg2 = np.zeros((8,64,diff))
#For each sbox, for each keyguess, count how many traces get dumped 
hdl2_count = np.ones((8,64))
hdg2_count = np.ones((8,64))

# We will loop through a constant 2000 tracess
for trace_num in xrange(1,501):
	if trace_num % 100 == 0:
		print trace_num
	ciphertext = redis.hget("%s" % RUN_NAME, "trace_%dc" % trace_num)
	ciphertext = ciphertext.decode("hex")
	trace = np.array(json.loads(redis.hget("%s" % RUN_NAME, "trace_%dy" % trace_num)), float)
	trace = trace[xMin:xMax]
	for sbox_num in xrange(0,8): # For each sbox
		for keyguess in xrange(0,64): # For each key
			# Calculate the hamming distance between the ciphertext and round 15 ciphertext
			# Using the particular sbox and keyguess
			hd = sum(des.computeHW1516(sbox_num, ciphertext, keyguess, hd=True))
			if hd < 2:
				hdl2[sbox_num][keyguess] += trace
				hdl2_count[sbox_num][keyguess] += 1
			elif hd > 2:
				hdg2[sbox_num][keyguess] += trace
				hdg2_count[sbox_num][keyguess] += 1

for sbox_num in xrange(0,8): #Now we will calculate our key guess
	dpSum = np.zeros((64, diff))
	for keyguess in xrange(0,64):
		#Subtract hd>2 and hd<2 vectors
		dpSum[keyguess] = (hdg2[sbox_num][keyguess] / hdg2_count[sbox_num][keyguess] - hdl2[sbox_num][keyguess] / hdl2_count[sbox_num][keyguess])

	matrixMax = np.zeros(64)
	for i in xrange(0,64):
		#Calculate the maximum of each keyguess vector
		matrixMax[i] = np.max(np.abs(dpSum[i]))
	#Choose the position (0-64) of the max, that will be our keyguess
	keyGuess = np.argmax(matrixMax)

	print "Sbox #%d keyguess is %d" % (sbox_num, keyGuess)
	if keyGuess != roundKey[sbox_num]:
		print "We got the round subkey for sbox %d" % sbox_num


















