#!/opt/local/bin/perl
use RRD::Simple;
use LWP::Simple;
use HTML::Tree;
use Data::Dumper;
use HTML::TreeBuilder::XPath;

my $url = "http://192.168.1.254/xslt?PAGE=C_2_0";
my $content = get($url);
#my $tree = HTML::Tree->new();
my $tree = HTML::TreeBuilder::XPath->new;

$tree->parse($content);
my @ports = $tree->findvalues('/html/body//table[5]//td');
$count = 0;
foreach my $port (@ports) {
	if ($port eq 'Wireless' || $port eq 'HomePNA1') {
		$current_interface = $port;
	}
	if ($port =~ /Port ([0-9]+) ([a-z]+)/i) {
		$dir = "Download" if ($2 eq "Transmit");
		$dir = "Upload" if ($2 eq "Receive");
		$data{"Port $1"}{$dir} = $ports[$count + 1] if ($ports[$count + 1] != 0);
	}
	if ($current_interface eq 'Wireless' && $port eq ' Transmit') {
		$data{'Wireless'}{'Download'} = $ports[$count + 1];
	} elsif ($current_interface eq 'Wireless' && $port eq ' Receive') {
		$data{'Wireless'}{'Upload'} = $ports[$count + 1];
	} elsif ($current_interface eq 'HomePNA1' && $port eq ' Transmit') {
		$data{'Coax'}{'Download'} = $ports[$count + 1];
	} elsif ($current_interface eq 'HomePNA1' && $port eq ' Receive') {
		$data{'Coax'}{'Upload'} = $ports[$count + 1];
	}
	$count++;
}
#print Dumper(%data);

foreach my $port (sort keys %data) {
print "Port: $port\n";
	print Dumper map { ( $_ => "GAUGE" ) } keys %{ $data{$port} };
	print Dumper map { ( $_ => $data{$port}{$_} ) } keys %{ $data{$port} };
	my $rrd = RRD::Simple->new(file => "${port}.rrd");
	$rrd->create(map { ($_ => "GAUGE" ) } keys %{ $data{$port} }) unless -f "${port}.rrd";
	$rrd->update("${port}.rrd", time(), map { ($_ => $data{$port}{$_}) } keys %{ $data{$port} });
	my %rtn = $rrd->graph(
		width => '600',
		height => '480',
		destination => '/Users/geoffeg/Sites/stats/',
                    title => "Network Interface $port",
                    vertical_label => 'Bytes/sec',
                    interlaced => ''
	);
	my $info = $rrd->info;
	print Dumper $info;
print "\n";
}

