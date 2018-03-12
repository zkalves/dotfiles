#!/usr/bin/python

# Replace upper case with lower case
# Replace spaces with underscores

import os, sys
if len(sys.argv) == 1:
   filenames = os.listdir(os.curdir)
else:
   filenames = sys.argv[1:]
for filename in filenames:
   newfilename = filename.lower()
   if ' ' in newfilename:
      newfilename = newfilename.replace(' ', '_')
   if '-' in newfilename:
      newfilename = newfilename.replace('-', '_')
   if newfilename != filename:
      print "Renaming", filename, "to", newfilename, "..."
      os.rename(filename, newfilename)
