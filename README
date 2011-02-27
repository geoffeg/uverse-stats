# uverse-stats

This perl script allows you to generate bandwidth usage graphs for any interface on a U-Verse residental gateway.

The script was developed against a 2Wire 3800HGV-B running version 6. It may not work against other versions or devices.

### Installation
1. You'll need to insall the required perl modules. Basically:

	# sudo perl -MCPAN -eshell
	... (answer "yes" if this if CPAN asks you to do a quick setup)
	... (answer "yes" to any pre-requsite module questions for the following modules)
	cpan[1]> install RRD::Simple
	cpan[1]> install LWP::Simple
	cpan[1]> install HTML::Tree
	cpan[1]> install Data::Dumper
	cpan[1]> install HTML::TreeBuilder::XPath

2. Edit uverse.pl and change @interfaces, $router_ip and $images_directory to your wishes.

3. Setup a crontab entry to run the script every minute. (replace ~/stats/uverse-stats with the location of the script

	* * * * * cd ~/stats/uverse-stats && ./uverse.pl

Please do not email me with questions related to installing perl modules. There are many guides on the web.
