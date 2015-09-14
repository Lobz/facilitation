
main: Facilitation main.cpp Random
	g++ -std=c++11 -Wall -pedantic -g Facilitation.o Random.o real_main.cpp -L/usr/lib64/R/lib -lR

Facilitation: Facilitation.cpp Facilitation.hpp Random.hpp
	g++ -std=c++11 -I/usr/share/R/include -Wall -pedantic -g -c Facilitation.cpp  -o Facilitation.o

Random:  Random.hpp Random.cpp Random.hpp
	g++ -std=c++11 -I/usr/share/R/include -Wall -pedantic -g -c  Random.cpp -o Random.o
