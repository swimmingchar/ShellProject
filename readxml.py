#!/usr/bin/python
# -*- coding:UTF-8 -*-

from xml.dom.minidom import parse
import xml.dom.minidom

DOMTree = xml.dom.minidom.parse("zbx_export_hosts.xml")
collection = DOMTree.documentElement
if collection.hasAttribute("shelf"):
	print "Root element : %s" % collection.getAttribute("shelf")

ips = collection.getElementsByTagName("ip")

for hosts_ip in ips:
	if hosts_ip.hasAttribute("ip"):
		print "IP:%s" % hosts_ip.getAttribute("ip")
