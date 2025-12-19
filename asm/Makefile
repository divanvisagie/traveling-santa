traveling-santa: main.s
	as -o main.o main.s
	ld -o $@ main.o -lSystem -syslibroot `xcrun --show-sdk-path` -e _main -arch arm64

clean:
	rm -f traveling-santa main.o
