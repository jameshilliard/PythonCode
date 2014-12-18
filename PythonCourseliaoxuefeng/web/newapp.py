#!/usr/bin/env python
# coding=utf-8
__author__ = 'root'

from flask import Flask, request, render_template

newapp = Flask(__name__)


@newapp.route('/', methods=['GET', 'POST'])
def home():
    return render_template('home.html')


@newapp.route('/signin', methods=['GET'])
def signin_form():
    return render_template('form.html')


@newapp.route('/signin', methods=['POST'])
def signin():
    username = request.form['username']
    password = request.form['password']
    if username == 'admin' and password == 'password':
        return render_template('signin-ok.html', username=username)
    return render_template('form.html', message='Bad username or password', username=username)


if __name__ == '__main__':
    newapp.run()