#!/usr/bin/perl
use RRD::Simple;
use LWP::Simple;
use Data::Dumper;
use HTML::TreeBuilder::XPath;

# Which interfaces to monitor, these MUST be in the order they appear on the web page
my @interfaces = ("Port 1", "Port 2", "Wireless", "HomePNA1");
my $router_ip = '192.168.1.254';
my $images_directory = '/Users/geoffeg/Sites/stats/';

###############################################################
##### There are no user-servicable parts below this line. #####
###############################################################

my $url = "http://$router_ip/xslt?PAGE=C_2_0";
my $content = get($url);

my $tree = HTML::TreeBuilder::XPath->new;
$tree->parse($content);
my @td_cells = $tree->findvalues('/html/body//table[5]//td');

my $count = 0;
my $interface = shift(@interfaces);
foreach my $td_cell (@td_cells) {
	$current_interface = $interface if ($td_cell =~ /$interface/);
	if ($current_interface eq $interface && $td_cell =~ /(Transmit|Receive)/) {
		$data{$interface}{$1} = $td_cells[$count + 1];
		$interface = shift(@interfaces) if ($1 eq "Receive");
	}
	$count++;
}
#print Dumper(%data);

foreach my $port (sort keys %data) {
	#print "Port: $port\n";
	#print Dumper map { ( $_ => "GAUGE" ) } keys %{ $data{$port} };
	#print Dumper map { ( $_ => $data{$port}{$_} ) } keys %{ $data{$port} };
	my $rrd = RRD::Simple->new(file => "${port}.rrd");
	$rrd->create(map { ($_ => "COUNTER" ) } keys %{ $data{$port} }) unless -f "${port}.rrd";
	$rrd->update("${port}.rrd", time(), map { ($_ => $data{$port}{$_}) } keys %{ $data{$port} });
	my %rtn = $rrd->graph(
		width => '600',
		height => '480',
		destination => $images_directory,
		title => "Network Interface $port",
		vertical_label => 'Bytes/sec',
		line_thickness => 2,
		extended_legend => 1,
		sources => [ qw(Receive Transmit) ],
		source_labels => [ ("Upload", "Download" ) ],
		source_drawtypes => [ ("LINE2", "LINE2") ],
		"slope-mode" => "",
		"units-exponent" => "3",
		"alt-autoscale" => "",
		"alt-autoscale-max" => ""
	);
	my $info = $rrd->info;
	#print Dumper $info;
	#print "\n";
}

