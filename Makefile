all: heat.cgi daemon ocr_main

CC = g++

CXXFLAGS += -O0 -g -std=gnu++14 -I/usr/include/opencv

CV_LIBS = `pkg-config --libs opencv`

LDFLAGS += -Wl,--as-needed

heat.cgi: cgi.o ipc.o urldecoder.o config.o base64.o
	$(CC) $(CXXFLAGS) $(LDFLAGS) -o heat.cgi $^

daemon: daemon.o ipc.o sg90.o camera.o ocr.o config.o signal_handler.o dir.o
	$(CC) $(CXXFLAGS) $(LDFLAGS) -o daemon $^ -lwiringPi -lwiringPiDev $(CV_LIBS)

ocr_main: ocr.o ocr_main.o
	$(CC) $(CXXFLAGS) $(LDFLAGS) -o ocr_main $^ $(CV_LIBS)

clean:
	rm -f *.o
	rm -f heat.cgi daemon ocr_main

install:
	mkdir -p /usr/lib/cgi-bin/heat/
	cp -f heat.cgi /usr/lib/cgi-bin/heat/heat.cgi
	chmod u+s /usr/lib/cgi-bin/heat/heat.cgi
	cp -f daemon /usr/lib/cgi-bin/heat/
	mkdir -p /var/www/html/heat/
	cp -f index.html /var/www/html/heat/
	
	mkdir -p /usr/lib/systemd/system
	cp -u heat.service /usr/lib/systemd/system/
	systemctl enable heat.service
	systemctl restart heat.service