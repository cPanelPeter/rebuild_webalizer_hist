#!/usr/bin/perl
# SCRIPT: rebuild_webalizer_hist.pl
# PURPOSE: rebuild a corrupted/empty or missing webalizer.hist file from the usage_YYYYMM.html
# files.  
# NOTE: THIS IS STILL A WORK IN PROGRESS! - PLEASE DO NOT USE THIS YET!
#
my $VERSION="0.1";

use strict;
use HTML::Strip;
use File::Copy qw(move);
#use Cpanel::Usage                      ();

# TODO: 
# Add backup section to backup current webalizer.hist if it exists.

my $ACCT=@ARGV[0];
chomp($ACCT);
if ($ACCT eq "") {
   &Usage;
}

my $HomeDir;
my $BASEDIR;
my @BASEDIR;
open(PASSWD,"/etc/passwd");
@PASSWDS=<PASSWD>;
close(PASSWD);
foreach $passline(@PASSWDS) {
   chomp($passline);
   if ($passline =~ m/\b$ACCT\b/) {
      ($HomeDir)=(split(/:/,$passline))[5];
      last;
   }
}
if (!($HomeDir)) { 
   print "Error: $ACCT not found!\n";
   exit;
}
else { 
   $BASEDIR="$HomeDir/tmp/webalizer";
}

# Backup current webalizer.hist file (if it exists)
my $now = time();
my $backupfilename="webalizer.hist.$now";
print "Backing up $BASEDIR/webalizer.hist to $BASEDIR/$backupfilename\n";
move ("$BASEDIR/webalizer.hist" "$BASEDIR/$backupfilename");

opendir(BASEDIR,"$BASEDIR");
@BASEDIR=readdir(BASEDIR);
closedir(BASEDIR);

# first we need to sort the usage_ files by date order (newest first).  
foreach $FILE(@BASEDIR) { 
   chomp($FILE);
   if (substr($FILE,0,6) eq "usage_") { 
      $FILE =~ s/usage_//g;
      $FILE =~ s/\.html//g;
      push(@USAGEFILES,$FILE);
   }
}
@sorted=sort(@USAGEFILES);
@reversed=reverse(@sorted);
@USAGEFILES=undef;
splice(@USAGEFILES);
foreach $line(@reversed) {
   chomp($line);
   $newline = "usage_$line.html";
   push(@USAGEFILES,$newline);
}

# Now process each usage_YYYYMM.html file.
foreach $FILE(@USAGEFILES) { 
   chomp($FILE);
   $DATE=substr($FILE,6);
   $YEAR=substr($DATE,0,4);
   $MONTH=substr($DATE,4);
   $MONTH =~ s/\.html//g;
   $MONTH =~ s/^0//g;
   $x=0;
   @DATES=undef;
   open(FH,"$BASEDIR/$FILE");
   while (<FH>) {
      chomp($_);
      if ($_ =~ m/<B>(.*?)<\/B>/ and $x<6) { 
         my $hs = HTML::Strip->new();
         my $clean_text = $hs->parse( $_ );
         $hs->eof;
         push(@webstats, "$clean_text");
         $x++;   
      }   
      # Get first and last date (from range of dates 
      # between "Daily Statistics for" and "Hourly Statistics for"
      &process_dates() if /Daily Statistics for/;
   }
   close(FH);
   $first=shift(@DATES);
   $first=shift(@DATES);
   $last=pop(@DATES);
   chomp($first);
   chomp($last);
   if (@webstats[0] eq "") { 
      shift(@webstats);
   }
   $string = "$MONTH $YEAR @webstats[0] @webstats[1] @webstats[5] @webstats[4] $first $last @webstats[2] @webstats[3]";
   #print "$string\n";
   open(NEW,">>$BASEDIR/webalizer.hist");
   print NEW "$string\n";
   close(NEW); 
   @webstats=undef;
}

sub process_dates {
   while ($line = <FH>, $line !~ /Hourly Statistics for/) {
      if ($line =~ m/^<TR BGCOLOR=/ or $line =~ m/^<TR><TD ALIGN=center><FONT SIZE="-1"><B>/) {
         my $hs = HTML::Strip->new();
         my $clean_date = $hs->parse( $line );
         $hs->eof;
         push(@DATES,$clean_date);
      }
   }
}       


sub Usage { 
   print "Usage: ./rebuild_webalizer_hist cPanelUser\n";
   exit;
}
