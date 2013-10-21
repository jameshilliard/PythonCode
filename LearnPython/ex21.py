__author__ = 'royxu'

def add(a, b):
    print " Adding %d + %d" % (a,b)
    return a + b

def subtract(a, b):
    print " subtracting %d - %d" % (a,b)
    return a - b

def multiply (a,b):
    print "multiplying %d * %d" % (a,b)
    return a * b

def divide(a, b):

    print " dividing %d / %d " % (a, b)
    return a / b


print "Let's do some math with just function !"

age = add(30,5)

height = subtract(78,6)

weight = multiply(90,2)

iq = divide(100,2)

print "Aga : %d, Height: %d, Weight: %d, IQ: %d" % (age, height,weight,iq)

print "Here is puzzle "

what = add(age,subtract(height,multiply(weight,divide(iq,2))))

print "That becomes: ", what, "Can you do it by hand?"