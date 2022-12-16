#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  8 14:20:34 2022

@author: raychandonnet
"""

def palindrome_for(eval_str):
    if len(eval_str)==0:
        is_palindrome=False
    else:
        is_palindrome=True
        mid_point=int(len(eval_str)/2)
        opp_counter = len(eval_str)-1
        for counter in range(mid_point) :
#            print("Comparing character",counter,"to character",opp_counter)
#            print("Comparing '",eval_str[counter],"' to '",eval_str[opp_counter],"'")
            if eval_str[counter] != eval_str[opp_counter] :
                is_palindrome=False
                break
            opp_counter -= 1
    return is_palindrome   

print("'level':",palindrome_for("level"))
print("'leveel':",palindrome_for("leveel"))
print("'hannah':",palindrome_for("hannah"))
print("'hanaah':",palindrome_for("hanaah"))
print("If no string provided: ",palindrome_for(""))
print("My favorite - 'amanaplanacanalpanama':",palindrome_for("amanaplanacanalpanama"))
print("Misspelled - 'amanaplanaacanalpanama':",palindrome_for("amanaplanaacanalpanama"))

def palindrome_while(eval_str):
    if len(eval_str)==0:
        is_palindrome=False
    else:
        is_palindrome=True
        mid_point=int(len(eval_str)/2)
        counter = 0
        opp_counter = len(eval_str)-1
        while is_palindrome and counter<=mid_point:
#            print("Comparing character",counter,"to character",opp_counter)
#            print("Comparing '",eval_str[counter],"' to '",eval_str[opp_counter],"'")
            if eval_str[counter] != eval_str[opp_counter] :
                is_palindrome=False
            else:
                counter += 1
                opp_counter -= 1
    return is_palindrome   

print("'level':",palindrome_while("level"))
print("'leveel':",palindrome_while("leveel"))
print("'hannah':",palindrome_while("hannah"))
print("'hanaah':",palindrome_while("hanaah"))
print("If no string provided: ",palindrome_while(""))
print("My favorite - 'amanaplanacanalpanama':",palindrome_while("amanaplanacanalpanama"))
print("Misspelled - 'amanaplanaacanalpanama':",palindrome_while("amanaplanaacanalpanama"))

# Question 3
from collections import defaultdict
def two_sum(nums_vector,target):
#    
# This function takes in a vector of values and a target value, and finds the
# first combination of indices such that the values in the vector at those indices
# adds up to the target value
#
# Inputs: nums_vector = The vector of values to be searched
# target = The target sum being sought
#
# Output: The function returns a vector (list) containing the two indexes whose values add up to target
# The function will print an error message 
    argumentsOK=True
    if len(nums_vector) < 2:
        print("ERROR: Number vector must have at least two values")
        argumentsOK = False
    if len(nums_vector)>104 :
        print("ERROR: Number vector cannot exceed 104 values")
        argumentsOK = False
    if min(nums_vector) < -109 :
        print("ERROR: All values in vector must be >= -109")
        argumentsOK = False
    if max(nums_vector) > 109 :
        print("ERROR: All values in vector must be <= 109")
        argumentsOK = False
    if target < -109 :
        print("ERROR: Target sum must be >= -109")
        argumentsOK = False
    if target > 109 :
        print("ERROR: Target sum must be <= 109")
        argumentsOK = False
# If any error was triggered, abort the function
    if not argumentsOK: 
        print("Function Aborted Due to bad argument(s) above")
        return 
    else:
        def def_value():
            return "Not Present"                   
        hash_table=defaultdict(def_value)
        for counter1 in range(len(nums_vector)):
            hash_table[nums_vector[counter1]] = counter1
        counter2=0
        match_found=False
        while counter2 <= len(nums_vector) and not match_found:
            search_key = target-nums_vector[counter2] # this is the complement we're looking for
            match_location = hash_table[search_key]
            if match_location != def_value() and match_location != counter2:
                match = [counter2,match_location]
                match_found=True
            else:
                counter2 += 1
    return match

# Prove that error checking works
nums_vector=[1]
two_sum(nums_vector,2)
nums_vector=list(range(1,106))
two_sum(nums_vector,2)
nums_vector=list(range(-110,-10))
two_sum(nums_vector,2)
nums_vector=list(range(100,111))
two_sum(nums_vector,2)
nums_vector=list(range(1,101))
two_sum(nums_vector,-110)
two_sum(nums_vector,110)
nums_vector=list(range(-120,120))
target=200
two_sum(nums_vector,target)

# Now run function on test cases
nums_vector = [2,7,11,15]
target = 9
print(two_sum(nums_vector,target))
nums_vector = [3,2,4]
target = 6
print(two_sum(nums_vector,target))
nums_vector = [3,3]
target = 6
print(two_sum(nums_vector,target))
nums_vector = [1,3,6,10,15,21,28,36,45,55,66,78,91,105]
target=97
print(two_sum(nums_vector,target))
target=73
print(two_sum(nums_vector,target))

# Question 4
def palindrome_easy(eval_str):
    if len(eval_str)==0:
        return False
    else:
        backwards = eval_str[::-1]
        is_palindrome= backwards == eval_str
    return is_palindrome

print("'level':",palindrome_easy("level"))
print("'leveel':",palindrome_easy("leveel"))
print("'hannah':",palindrome_easy("hannah"))
print("'hanaah':",palindrome_easy("hanaah"))
print("If no string provided: ",palindrome_easy(""))
print("My favorite - 'amanaplanacanalpanama':",palindrome_easy("amanaplanacanalpanama"))
print("Misspelled - 'amanaplanaacanalpanama':",palindrome_easy("amanaplanaacanalpanama"))

# Question 5         
def isomorphic(str1, str2):
    def def_value():
        return "Not Present"      
    if len(str1) != len(str2):
        return False
    else:
        char_maps = defaultdict(def_value)
        counter=0
        is_isomorphic = True
        while counter < len(str1) and is_isomorphic: 
            if char_maps[str1[counter]] != def_value() and char_maps[str1[counter]] != str2[counter]:
                is_isomorphic = False
            else:
                char_maps[str1[counter]]=str2[counter]
                counter +=1
    return is_isomorphic
str1="aab"
str2="xxy"
print(isomorphic(str1, str2))
str1="aab"
str2="xyz"
print(isomorphic(str1, str2))
str1="aabbccddabcddcba"
str2="wwxxyyzzwxyzzyxw"
print(isomorphic(str1, str2))
str1="aabbccddabcddcba"
str2="wwxxyyzzwxyzayxw"
print(isomorphic(str1, str2))