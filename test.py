#!/usr/bin/env python

###Easy examples


x = 1
if x == 1:
    # indented four spaces
    print "x is 1."

print "x is 1."


print "\n####Variable types\n"

###Different varibale type

# change this code
mystring = "hello"
myfloat = float(10)
myint = 20

# testing code
if mystring == "hello":
    print "String: %s" % mystring
if isinstance(myfloat, float) and myfloat == 10.0:
    print "Float: %d" % myfloat
if isinstance(myint, int) and myint == 20:
    print "Integer: %d" % myint

print "\n####Lists\n"


####list (similar to array))

mylist = []
mylist.append(1)
mylist.append(2)
mylist.append(3)
print(mylist[0]) # prints 1
print(mylist[1]) # prints 2
print(mylist[2]) # prints 3

# prints out 1,2,3


numbers = [1,2,3]

strings = []
strings.append("hello")
strings.append("world")


names = ["John", "Eric", "Jessica"]

# write your code here
second_name = names[1]


# this code should write out the filled arrays and the second name in the names list (Eric).
print(numbers)
print(strings)
print("The second name on the names list is %s" % second_name)

for x in numbers:   print x

#not working
#print(numbers[10])


print "\n####Concatenation of variables\n"

#concat strings
helloworld = "hello" + " " + "world"


#muliply strings
lotsofhellos = "hello" * 10


##joining lists
even_numbers = [2,4,6,8]
odd_numbers = [1,3,5,7]
all_numbers = odd_numbers + even_numbers

##repeating lists
print [1,2,3] * 3



####exercise on concatenation
x = object()
y = object()

x_list =10*[x]
y_list = 10*[y]
big_list = [x,y]*10

print "x_list contains %d objects" % len(x_list)
print "y_list contains %d objects" % len(y_list)
print "big_list contains %d objects" % len(big_list)

# testing code
if x_list.count(x) == 10 and y_list.count(y) == 10:
    print "Almost there..."
if big_list.count(x) == 10 and big_list.count(y) == 10:
    print "Great!"

###

#
#http://www.learnpython.org/en/String_Formatting

print "\n####Format output\n"


###format output
# This prints out "John is 23 years old."
name = "John"
age = 23
print "%s is %d years old." % (name, age)

###exercise
first="John"
second="Doe"
money=float(53.44)

print "Hello %s %s. Your current balance is %.2f$" % (first, second, money)



###string checking
print "\n####Check strings\n"
astring = "Hello world!"

print len(astring)
print astring.index("o")
print astring.count("l")
print astring[3:7]
print astring[3:7:2]
print astring.lower()


s = "Str therass whatome!"
# Length should be 20
print "Length of s = %d" % len(s)

# First occurrence of "a" should be at index 8
print "The first occurrence of the letter a = %d" % s.index("a")

# Number of a's should be 2
print "a occurs %d times" % s.count("a")

# Slicing the string into bits
print "The first five characters are '%s'" % s[:5] # Start to 5
print "The next five characters are '%s'" % s[5:10] # 5 to 10
print "The twelfth character is '%s'" % s[12] # Just number 12
print "The characters with odd index are '%s' " %s[1::2] #(0-based indexing)
print "The last five characters are '%s'" % s[-5:] # 5th-from-last to end

# Convert everything to uppercase
print "String in uppercase: %s" % s.upper()

# Convert everything to lowercase
print "String in lowercase: %s" % s.lower()

# Check how a string starts
if s.startswith("Str"):
    print "String starts with 'Str'. Good!"

# Check how a string ends
if s.endswith("ome!"):
    print "String ends with 'ome!'. Good!"

# Split the string into three separate strings,
# each containing only a word
print "Split the words of the string: %s" % s.split(" ")
