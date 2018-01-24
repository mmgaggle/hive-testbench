#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use POSIX qw/strftime/;
use IO::Handle;

# PROTOTYPES
sub dieWithUsage(;$);

# GLOBALS
my $SCRIPT_NAME = basename( __FILE__ );
my $SCRIPT_PATH = dirname( __FILE__ );

# MAIN
dieWithUsage("one or more parameters not defined") unless @ARGV >= 4;
my $query_dir = shift;
my $run_id = shift;
my $engine = shift;
my $format = shift;
my $scale = shift || 2;
my $coordinator = shift || "localhost:8880";
dieWithUsage("suite name required") unless $engine eq "hive" or $engine eq "hive-spark" or $engine eq "spark" or $engine eq "presto" or $engine eq "impala";
dieWithUsage("suite name required") unless $format eq "orc" or $format eq "parquet";

chdir $SCRIPT_PATH;
chdir $query_dir;

my $filename = "tpc_stats_${run_id}.log";
open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";

#my @queries = glob '*.sql';
my @queries = split(/\s/, `cat run_order_${run_id}.txt`);

my $db = "tpcds_bin_partitioned_${format}_$scale";
for my $query ( @queries ) {
	my $logname = "${engine}_${format}_${scale}_${query}_${run_id}";

        my $cmd = {
                'hive' => "echo 'use $db; source $query;' | hive -i ../testbench.settings 2>&1  | tee $logname.log",
                'hive-spark' => "echo 'use $db; source $query;' | hive -i ../testbench_hive-spark.settings 2>&1  | tee $logname.log",
                'spark' => "spark-sql --master=yarn --database $db -f $query --properties-file ../testbench_spark.settings 2>&1 1>$logname.out | tee $logname.log",
	        'presto' => "presto --server $coordinator --catalog hive --schema $db --file $query 2>&1 1>$logname.out | tee $logname.log",
                'impala' => "impala-shell -i $coordinator -d $db -f $query 2>&1 1>$logname.out | tee $logname.log"
        };

	my $hiveStart = time();
        my $hiveStartFmt = strftime('%Y-%m-%d %H:%M:%S',localtime($hiveStart));

	my @hiveoutput=`$cmd->{${engine}}`;
	die "${SCRIPT_NAME}:: ERROR:  command unexpectedly exited \$? = '$?', \$! = '$!'" if $?;

	my $hiveEnd = time();
        my $hiveEndFmt = strftime('%Y-%m-%d %H:%M:%S',localtime($hiveEnd));
	my $hiveTime = $hiveEnd - $hiveStart;
        if ($engine eq 'hive' or $engine eq "hive-spark" or $engine eq "spark") {
                my $output = '';
	        foreach my $line ( @hiveoutput ) {
		        if( $line =~ /Time taken:\s+([\d\.]+)\s+seconds,\s+Fetched:*\s+(\d+)\s+row/ ) {
			        $output = "$query_dir,$run_id,$engine,$format,$scale,$query,success,$hiveStartFmt,$hiveEndFmt,$hiveTime,$1,$2\n"; 
		        } # end if
	        } # end while
	        if ( $output eq '' ) {
		        $output = "$query_dir,$run_id,$engine,$format,$scale,$query,failed,$hiveStartFmt,$hiveEndFmt,$hiveTime,,\n"; 
                }
	        print $fh $output;
        } elsif ($engine eq 'impala' ) {
                my $output = '';
	        foreach my $line ( @hiveoutput ) {
		        if( $line =~ /Fetched (\d+) row\(s\) in (\d+).(\d+)s/) {
			        $output = "$query_dir,$run_id,$engine,$format,$scale,$query,success,$hiveStartFmt,$hiveEndFmt,$hiveTime,$2.$3,$1\n"; 
		        } # end if
	        } # end while
                if ( $output eq '' ) {
                        $output = "$query_dir,$run_id,$engine,$format,$scale,$query,failed,$hiveStartFmt,$hiveEndFmt,$hiveTime,,\n";
                }
                print $fh $output;
        } else {
                my $rows = `wc -l $logname.out`;
                my @row = split(/\s/, $rows);
                if (not(@hiveoutput)) {
                        print $fh "$query_dir,$run_id,$engine,$format,$scale,$query,success,$hiveStartFmt,$hiveEndFmt,$hiveTime,$hiveTime,$row[0]\n";
                } else {
                        print $fh "$query_dir,$run_id,$engine,$format,$scale,$query,failed,$hiveStartFmt,$hiveEndFmt,$hiveTime,,\n";
                }
        }
        $fh->flush();
} # end for
close $fh;

sub dieWithUsage(;$) {
	my $err = shift || '';
	if( $err ne '' ) {
		chomp $err;
		$err = "ERROR: $err\n\n";
	} # end if

	print STDERR <<USAGE;
${err}Usage:
	perl ${SCRIPT_NAME} [query_dir] [hive|hive-spark|spark|presto] [orc|parquet] [scale] [coordinator]

Description:
	This script runs the sample queries and outputs a CSV file of the time it took each query to run.  Also, all hive output is kept as a log file named '[hive|hive-spark|spark|presto|impala]_[orc|parquet]_[scale]_queryXX.sql.log' for each query file of the form 'queryXX.sql'. Defaults to scale of 2.
USAGE
	exit 1;
}

