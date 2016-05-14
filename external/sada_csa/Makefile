CC=g++
CFLAGS=-O9 -DNDEBUG 

all: index

suftest3.test.o: suftest3.test.cpp
	$(CC) $(CFLAGS) -c suftest3.test.cpp
comparray4.o: comparray4.cpp
	$(CC) $(CFLAGS) -c comparray4.cpp
qsufsort.o: qsufsort.cpp
	$(CC) $(CFLAGS) -c qsufsort.cpp
mmap.o: mmap.cpp
	$(CC) $(CFLAGS) -c mmap.cpp

index: suftest3.test.o comparray4.o mmap.o qsufsort.o
	ar rcv csa.a suftest3.test.o comparray4.o mmap.o qsufsort.o

run_queries: index
	$(CC) $(CFLAGS) run_queries.c -o run_queries suftest3.test.o mmap.o qsufsort.o comparray4.o

build_index: index
	$(CC) $(CFLAGS) build_index.c -o build_index suftest3.test.o mmap.o qsufsort.o comparray4.o

all: run_queries build_index

clean:
	-rm *~ *.o *.bak 
cleanall:
	-rm *~ *.o *.bak .a

tarfile:
	tar zcvf sada_csa.tgz ?akefile 386.c mman.h suftest3.test.* comparray4.* qsufsort.* mmap.* COPYRIGHT README
