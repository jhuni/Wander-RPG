package Map::Grid;

use strict;
use warnings;

use Trigedit::Scalar;
use Trigedit::Core qw(:std);
use Trigedit::Memory;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(LocationChain MoveToY getXLocations createGridSystem);

# These are the x, y variables related to the current pointer
our ($x, $y) = vars(320, 464);

# This is a general purpose utility not related to the map itself
# This is for locations on locations on locations
sub LocationChain {
	my @args = @_;
	
	# Leave if we don't have enough args
	return if scalar(@args) < 2;
	
	# Now build the actions:
	MoveLocation("Player 1", "Map Revealer", $args[$_], $args[$_+1]) for 0..($#args-1);
}

# This is for y coordinates
sub MoveToY {
	my ($location, $y) = @_;
	
	my @units = (
		"Zerg Zergling",
		"Devouring One (Zergling)",
		"Zerg Hydralisk",
		"Hunter Killer (Hydralisk)",
		"Zerg Lurker",
		"Zerg Defiler",
		"Unclean One (Defiler)",
		"Infested Terran",
		"Zerg Drone",
		"Vulture Spider Mine"
	);
	
	my @players = ("Player 9", "Player 10", "Player 11", "Player 12");
	my @locations = (
		"Yu1", "Yu2", "Yu3", "Yu4", "Yu5", "Yu6", 
		"Yu7", "Yu8", "Yu9", "Yu10", "Yu11", "Yu12"
	);
	
	my @args = ();
	
	if ($y <= 464) {
		my $location = int(($y) / 40);
		$y = ($y % 40);
		my $player = int($y / 10);
		my $unit = ($y) % 10;
		
		@args = ($players[$player], $units[$unit], $locations[$location]);
	}
	
	push @args, $location;
	MoveLocation(@args);
	
}

# This is for x coordinates
sub getXLocations {
	my ($leftx, $rightx, $x) = @_;
	
	if ($x == 0) {
		return ($leftx);
	} elsif ($x < 160) {
		return ($leftx, "X". ($x+1));
	} else {
		return ($rightx, "X" . (320-$x));
	}
	
}

# This will create the grid system which can place locations in a 7x7 grid
sub createGridSystem {
	
	# The y business (to 457)
	for (my $i = 0; $i <= 457; $i++) { 
		If {
			$y == ($i + 1);
		} Then {
			MoveToY("G6,$_", $i + $_) for 0..6;
		};
	}

	# The x business (to 313)
	for (my $i = 0; $i <= 313; $i++) {		
		If {
			$x == ($i + 1);
		} Then {
			for (my $y = 0; $y < 7; $y++) { 
		
				my $rightx = "G6,$y";
				my $leftx = "Xshift";
				
				# X shift if necessary:
				LocationChain($rightx, $leftx) if $i < 160;
				
				for (my $x = 0; $x < 7; $x++) {
					LocationChain(getXLocations($leftx, $rightx, $i+$x), "G$x,$y");
				}
				
			}
		};
	}
		
}

1;