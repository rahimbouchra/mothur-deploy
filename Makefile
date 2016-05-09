###################################################
#
# Makefile for mothur
#
###################################################

#
# Macros
#

64BIT_VERSION ?= yes
OPTIMIZE ?= yes
USEREADLINE ?= no
USEBOOST ?= yes
#BOOST_LIBRARY_DIR="\"Enter_your_boost_library_path_here\""
BOOST_LIBRARY_DIR="${BOOST_DIR}/lib"
BOOST_INCLUDE_DIR="${BOOST_DIR}/include"
MOTHUR_FILES="\"Enter_your_default_path_here\""
RELEASE_DATE = "\"4/18/2016\""
VERSION = "\"1.37.1\""

ifeq  ($(strip $(64BIT_VERSION)),yes)
    CXXFLAGS += -DBIT_VERSION
endif

# Fastest
ifeq  ($(strip $(OPTIMIZE)),yes)
    CXXFLAGS += -O3
endif

CXXFLAGS += -DRELEASE_DATE=${RELEASE_DATE} -DVERSION=${VERSION} -O3

ifeq  ($(strip $(MOTHUR_FILES)),"\"Enter_your_default_path_here\"")
else
    CXXFLAGS += -DMOTHUR_FILES=${MOTHUR_FILES}
endif


# if you do not want to use the readline library, set this to no.
# make sure you have the library installed


ifeq  ($(strip $(USEREADLINE)),yes)
    CXXFLAGS += -DUSE_READLINE
    LIBS += -lreadline
endif


#The boost libraries allow you to read gz files.
ifeq  ($(strip $(USEBOOST)),yes)

#User specified boost library path
ifeq  ($(strip $(BOOST_LIBRARY_DIR)),"\"Enter_your_boost_library_path_here\"")
else
    LDFLAGS += -L${BOOST_LIBRARY_DIR}
endif

    LIBS += -lboost_iostreams -lz
    CXXFLAGS += -DUSE_BOOST -I${BOOST_INCLUDE_DIR}
endif

#
# INCLUDE directories for mothur
#
#
    VPATH=source/calculators:source/chimera:source/classifier:source/clearcut:source/commands:source/communitytype:source/datastructures:source/metastats:source/randomforest:source/read:source/svm
    skipUchime := source/uchime_src/
    subdirs :=  $(sort $(dir $(filter-out  $(skipUchime), $(wildcard source/*/))))
    subDirIncludes = $(patsubst %, -I %, $(subdirs))
    subDirLinking =  $(patsubst %, -L%, $(subdirs))
    CXXFLAGS += -I. $(subDirIncludes)
    LDFLAGS += $(subDirLinking)


#
# Get the list of all .cpp files, rename to .o files
#
    OBJECTS=$(patsubst %.cpp,%.o,$(wildcard $(addsuffix *.cpp,$(subdirs))))
    OBJECTS+=$(patsubst %.c,%.o,$(wildcard $(addsuffix *.c,$(subdirs))))
    OBJECTS+=$(patsubst %.cpp,%.o,$(wildcard *.cpp))
    OBJECTS+=$(patsubst %.c,%.o,$(wildcard *.c))

mothur : $(OBJECTS) uchime
	$(CXX) $(LDFLAGS) $(TARGET_ARCH) -o $@ $(OBJECTS) $(LIBS)

uchime:
	cd source/uchime_src && ./mk && mv uchime ../../ && cd ..

install : mothur


%.o : %.c %.h
	$(COMPILE.c) $(OUTPUT_OPTION) $<
%.o : %.cpp %.h
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
%.o : %.cpp %.hpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<



clean :
	@rm -f $(OBJECTS)
	@rm -f uchime
