#!/usr/bin/env python
#coding=utf-8

inputs = driver.find_elements_by_tag_name("input")

for input in inputs:
    
    if input.get_attribute('data-node') == '55554345353':
        input.click()