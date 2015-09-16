objects = Facilitation.o Random.o Species.o Individual.o Position.o

main: $(objects) main.cpp real_main.cpp
	g++ -std=c++11 -Wall -pedantic -g $(objects) real_main.cpp -L/usr/lib64/R/lib -lR -o main

Random.o:  Random.hpp Random.cpp 
Facilitation: Facilitation.cpp Facilitation.hpp Random.hpp
Species.o: Species.cpp Facilitation.hpp Random.hpp
Individual.o: Individual.cpp Facilitation.hpp Random.hpp
Position.o: Position.cpp Position.hpp


.cpp.o: 
	g++ -std=c++11 -I/usr/share/R/include -Wall -pedantic -g -c  $< -o $@

debug: main
	gdb main

run: main
	./main < input.txt

clean:
	rm $(objects)
