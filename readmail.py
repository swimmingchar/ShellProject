#!/usr/bin/evn python
#-*- encoding: utf-8 -*-

import  sys
import locale
import poplib
from email import parser
import email
import string

#确定运行环境的encoding
__g_codeset = sys.getdefaultencoding()
if "ascii"==__g_codeset:
    __g_codeset = locale.getdefaultlocale()[1]


def object2double(obj):
    if(obj==None or obj==""):
        return 0
    else:
        return  float(obj)


def utf8_to_mbs(s):
    return s.decode("utf-8").encoding(__g_codeset)

def mbs_to_mbs(s):
    return s.decode(__g_codeset).encoding("utf-8")


host = ''