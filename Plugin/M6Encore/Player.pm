package Plugins::M6Encore::Player;

use strict;
use vars qw(@ISA);

use Slim::Utils::Log;
use Slim::Utils::Prefs;

my $prefs = preferences('server');

BEGIN {
	require Slim::Player::Transporter;
	push @ISA, qw(Slim::Player::Transporter);
}

sub model { 'm6encore' }

sub modelName { 'M6 Encore' }

# We need to overwrite this method in order to pass the $client->model string to valueForSourceName
sub setDigitalInput {
	my $client = shift;
	my $input  = shift;

	my $log    = logger('player.source');

	# convert a source: url to a number, otherwise, just use the number
	if (Slim::Music::Info::isDigitalInput($input)) {
	
		main::INFOLOG && $log->info("Got source: url: [$input]");

		if ($INC{'Slim/Plugin/DigitalInput/Plugin.pm'}) {

			$input = Slim::Plugin::DigitalInput::Plugin::valueForSourceName($input, $client->model);

			# make sure volume is set, without changing temp setting
			$client->volume( abs($prefs->client($client)->get("volume")), defined($client->tempVolume()));
		}
	}

	main::INFOLOG && $log->info("Switching to digital input $input");

	$prefs->client($client)->set('digitalInput', $input);
	$client->sendFrame('audp', \pack('C', $input));
}

1;

__END__
