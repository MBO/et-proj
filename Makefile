YOPTS=--report=all
#LOPTS=-d

default: main

parser.c: parser.y
	bison $(YOPTS) -d -o parser.c parser.y

parser.h: parser.c

lekser.c: lekser.l parser.h
	flex $(LOPTS) -o lekser.c lekser.l

clean:
	rm parser.c parser.h lekser.c || true
	rm main.exe || true

main: parser.c lekser.c
	gcc -g -o main parser.c lekser.c -Wall

run: main
	./main
