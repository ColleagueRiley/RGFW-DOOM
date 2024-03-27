CC = gcc

LIBS := -I./include -lshell32 -lXInput -lgdi32 -lm -ggdb -lShcore -lWinmm -lSDL2
EXT = .exe

ifeq ($(CC),x86_64-w64-mingw32-gcc)
	STATIC = --static
endif

ifneq (,$(filter $(CC),winegcc x86_64-w64-mingw32-gcc))
    detected_OS := Windows
	LIB_EXT = .dll
else
	ifeq '$(findstring ;,$(PATH))' ';'
		detected_OS := Windows
	else
		detected_OS := $(shell uname 2>/dev/null || echo Unknown)
		detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
		detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
		detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
	endif
endif

ifeq ($(detected_OS),Windows)
	LIBS := -lXInput -ggdb -lWinmm -lshell32 -lgdi32 -lShcore -lm -ldwmapi $(STATIC) -I C:\VulkanSDK\1.3.275.0\Include -L C:\VulkanSDK\1.3.275.0\Lib -lvulkan1
	EXT = .exe
endif
ifeq ($(detected_OS),Darwin)        # Mac OS X
	LIBS := -I./ext/Silicon/ -lm -framework Foundation -framework AppKit -framework OpenGL -framework CoreVideo -w $(STATIC)
	EXT = 
endif
ifeq ($(detected_OS),Linux)
    LIBS := -I./include -lXrandr -lX11 -lm $(STATIC)
	EXT = 
endif

all:
	make miniDoomedstb.o
	$(CC) source/main.c miniDoomedstb.o  -O3 $(LIBS) -I./ -Wall -o RGFWDoom$(EXT)

miniDoomedstb.o:
	gcc -c source/miniDoomedRGFWstb.c -I./include

clean:
	rm -f RGFWDoom RGFWDoom$(EXTT)

debug:
	make clean
	make miniDoomedstb.o

	$(CC) source/main.c miniDoomedstb.o $(LIBS) -I./ -Wall -D RGFW_DEBUG -o RGFWDoom
	./RGFWDoom$(EXT)