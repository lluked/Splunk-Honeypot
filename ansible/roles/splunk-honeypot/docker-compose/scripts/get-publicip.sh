#!/bin/bash
PUBLIC_IP=$(curl -s 'http://ipv4.icanhazip.com/') 
echo PUBLIC_IP=${PUBLIC_IP} > ip.env
