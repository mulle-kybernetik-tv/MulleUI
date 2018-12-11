
.PHONY:	all

all:	dillex1 uievent

dillex1:
	cc -o dillex1 dillex1.c -L../dependency/lib -I../dependency/include -I../src ../dependency/lib/libdill.a -lpthread

uievent:
	cc -o uievent uievent.c -L../dependency/lib -I../dependency/include -I../src ../dependency/lib/libdill.a -lpthread
