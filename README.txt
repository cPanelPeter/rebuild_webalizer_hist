# rebuild_webalizer_hist
Rebuild a corrupted or empty/missing webalizer.hist file from usage_YYYYMM.html files

Webalizer works by generating static HTML files for each domain. 
Each month’s history within that domain is stored in usage_YYYYMM.html files. 

Sometimes in rare situations, you will have a bunch of those usage_YYYYMM.html files, but
the webalizer.hist file will either be missing or will look like this: 

# Webalizer V2.23-05 History Data - 21/Feb/2015 14:43:57 (120 month)
2 2015 2 0 1 1 21 21 2 1
1 2015 22 17 1 839 17 17 1 1
12 2014 0 0 0 0 0 0 0 0
11 2014 0 0 0 0 0 0 0 0
10 2014 0 0 0 0 0 0 0 0

...  rest of the file is all like this with 0's in every section.

This script when run will parse the usage_YYYYMM.html files and grab the data
and re-create the webalizer.hist file.  

After running this, your Webalizer history should be back to normal. 
Please note though that Webalizer only stores 1 year worth of history.  
So if you have lost more than 1 year, you will probably only be able to 
get back one year despite having previous years usage_YYYYMM.html files.




