#!/usr/bin/env python3.3

###Easy examples


x = 1
if x == 1:
    # indented four spaces
    print( "x is 1.")

print("x is 1.")


print("\n####Variable types\n")

###Different varibale type

# change this code
mystring = "hello"
myfloat = float(10)
myint = 20

# testing code
if mystring == "hello":
    print("String: %s" % mystring)
if isinstance(myfloat, float) and myfloat == 10.0:
    print("Float: %d" % myfloat)
if isinstance(myint, int) and myint == 20:
    print("Integer: %d" % myint)

print("\n####Lists\n")


####list (= array))

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

for x in numbers:   print(x)

#not working
#print(numbers[10])


print("\n####Concatenation of variables\n")

#concat strings
helloworld = "hello" + " " + "world"


#muliply strings
lotsofhellos = "hello" * 10


##joining lists
even_numbers = [2,4,6,8]
odd_numbers = [1,3,5,7]
all_numbers = odd_numbers + even_numbers

##repeating lists
print([1,2,3] * 3)



####exercise on concatenation
x = object()
y = object()

x_list =10*[x]
y_list = 10*[y]
big_list = [x,y]*10

print("x_list contains %d objects" % len(x_list))
print("y_list contains %d objects" % len(y_list))
print("big_list contains %d objects" % len(big_list))

# testing code
if x_list.count(x) == 10 and y_list.count(y) == 10:
    print("Almost there...")
if big_list.count(x) == 10 and big_list.count(y) == 10:
    print("Great!")

###

#
#http://www.learnpython.org/en/String_Formatting

print("\n####Format output\n")


###format output
# This prints out "John is 23 years old."
name = "John"
age = 23
print("%s is %d years old." % (name, age))

###exercise
first="John"
second="Doe"
money=float(53.44)

print("Hello %s %s. Your current balance is %.2f$" % (first, second, money))



###string checking
print("\n####Check strings\n")
astring = "Hello world!"

print(len(astring))
print(astring.index("o"))
print(astring.count("l"))
print(astring[3:7])
print(astring[3:7:2])
print(astring.lower())


s = "Str therass whatome!"
# Length should be 20
print("Length of s = %d" % len(s))

# First occurrence of "a" should be at index 8
print("The first occurrence of the letter a = %d" % s.index("a"))

# Number of a's should be 2
print("a occurs %d times" % s.count("a"))

# Slicing the string into bits
print("The first five characters are '%s'" % s[:5]) # Start to 5
print("The next five characters are '%s'" % s[5:10]) # 5 to 10
print("The twelfth character is '%s'" % s[12]) # Just number 12
print("The characters with odd index are '%s' " %s[1::2]) #(0-based indexing)
print("The last five characters are '%s'" % s[-5:]) # 5th-from-last to end

# Convert everything to uppercase
print("String in uppercase: %s" % s.upper())

# Convert everything to lowercase
print("String in lowercase: %s" % s.lower())

# Check how a string starts
if s.startswith("Str"):
    print("String starts with 'Str'. Good!")

# Check how a string ends
if s.endswith("ome!"):
    print("String ends with 'ome!'. Good!")

# Split the string into three separate strings,
# each containing only a word
print("Split the words of the string: %s" % s.split(" "))


####boolean operations
# change this code
print("\n###boolean operations\n")

number = 20
second_number = 0
first_array = [1,3,3]
second_array = [1,2]

if number > 15:
    print("1")

if first_array:
    print("2")

if len(second_array) == 2:
    print("3")

if len(first_array) + len(second_array) == 5:
    print("4")

if first_array and first_array[0] == 1:
    print("5")

if not second_number:
    print("6")



##loop

print("\n###loop operations\n")

numbers = [
           951, 402, 984, 651, 360, 69, 408, 319, 601, 485, 980, 507, 725, 547, 544,
           615, 83, 165, 141, 501, 263, 617, 865, 575, 219, 390, 984, 592, 236, 105, 942, 941,
           386, 462, 47, 418, 907, 344, 236, 375, 823, 566, 597, 978, 328, 615, 953, 345,
           399, 162, 758, 219, 918, 237, 412, 566, 826, 248, 866, 950, 626, 949, 687, 217,
           815, 67, 104, 58, 512, 24, 892, 894, 767, 553, 81, 379, 843, 831, 445, 742, 717,
           958, 609, 842, 451, 688, 753, 854, 685, 93, 857, 440, 380, 126, 721, 328, 753, 470,
           743, 527
           ]


for x in numbers:
    if x % 2 == 0:
        print(x)
    if x==237:
        break



###pattern match #skipped to this step

print("\n###pattern match\n")

# Example:
import re
pattern = r"[^\{\}\?]+@.*..*" # Your pattern here!
# Doesn't return anything.
# End Example

# Exercise: make a regular expression that will match an email
def test_email(your_pattern):
    pattern = re.compile(your_pattern)
    emails = ["john@example.com", "python-list@python.org", "wha.t.`1an?ug{}ly@email.com"]
    for email in emails:
        if not re.match(pattern, email):
            print("You failed to match %s" % (email))
        elif not your_pattern:
            print("Forgot to enter a pattern!")
        else:
            print("Pass")

test_email(pattern)




#####Stopped here: http://www.learnpython.org/en/Functions

##functions

print("\n###Functions\n")

# Modify this function to return a list of strings as defined above
def list_benefits():
    return ("More organized code","More readable code","Easier code reuse","Allowing programmers to share and connect code together")

# Modify this function to concatenate to each benefit - " is a benefit of functions!"
def build_sentence(benefit):
    return benefit + " is a benefit of functions!"

def name_the_benefits_of_functions():
    list_of_benefits = list_benefits()
    for benefit in list_of_benefits:
        print(build_sentence(benefit))

name_the_benefits_of_functions()

####class

print("\n###Class\n")


# define the Vehicle class
class Vehicle:
    name = ""
    kind = "car"
    color = ""
    value = 100.00
    def description(self):
        desc_str = "%s is a %s %s worth $%.2f." % (self.name, self.color, self.kind, self.value)
        return desc_str
# your code goes here

car1=Vehicle()
car1.color="red"
car1.name="Fer"
car1.value=60000
car1.kind="convertible"

car2=Vehicle()
car2.color="blue"
car2.name="Jump"
car2.value=10000
car2.kind="van"

# test code
print(car1.description())
print(car2.description())


####Dictionary (=hash)

print("\n###Dictionaries\n")

phonebook = {
    "John" : 938477566,
    "Jack" : 938377264,
    "Jill" : 947662781
}

#

# write your code here
phonebook["Jake"] = 938273443
del phonebook["Jill"]

# testing code
if "Jake" in phonebook:
    print("Jake is listed in the phonebook.")
if "Jill" not in phonebook:
    print("Jill is not listed in the phonebook.")
