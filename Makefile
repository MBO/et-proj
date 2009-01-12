YOPTS=--report=all
#LOPTS=-d

default: main

parser.c: parser.y
	bison $(YOPTS) -d -o parser.c parser.y

parser.h: parser.c

lekser.c: lekser.l
	flex $(LOPTS) -o lekser.c lekser.l

clean:
	rm parser.c parser.h parser.output lekser.c || true
	rm main || true

main: parser.c lekser.c ast.h
	g++ -g -o main parser.c lekser.c -Wall

run: main
	./main
