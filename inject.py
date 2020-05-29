import lief
import sys

libnative = lief.parse(sys.argv[1]) 
libnative.add_library(sys.argv[2]) # Inject frida library as a dependency in the library
libnative.write(sys.argv[1])
