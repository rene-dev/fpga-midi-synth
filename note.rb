a = 440
clock = 100
clock = clock*1000000
root = 2**(1.0/12.0)

freq = Array.new

(-5..5).each {|j|(-9..2).each {|i|freq.push a/2.0**(j*-1)*(root**i)}}

(0..127).each {|i|
    print "x\"#{"%05x" % ((freq[i]/clock*2**30).to_i)}\", "
    #print (clock/freq[i].to_i)
    #print ','
    #if (i+1)%12 == 0
    #print "\n"
    #end
}

