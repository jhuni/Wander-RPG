package Trigedit::Memory;

use strict;
use warnings;

use Trigedit::Scalar;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(vars);

my @unkillable_units = ("Goliath Turret", "Tank Turret type 1", "Nuclear Missile", "Alan Turret", "Duke Turret type 1", "Duke Turret type 2", "Tank Turret type 2", "Scanner Sweep", "Map Revealer", "Disruption Field", "Unused type 1", "Unused type 2", "Uraj Crystal", "Khalis Crystal", "Unused Zerg Bldg", "Unused Zerg Bldg 5", "Unused Terran Bldg type 1", "Unused Terran Bldg type 2", "Protoss Unused type 1", "Protoss Unused type 2", "Khaydarin Crystal Formation", "Mineral Field (Type 1)", "Mineral Field (Type 2)", "Mineral Field (Type 3)", "Cave", "Cave-in", "Cantina", "Mining Platform", "Independent Command Center", "Independent Starport", "Jump Gate", "Ruins", "Kyadarin Crystal Formation", "Vespene Geyser", "Zerg Marker", "Terran Marker", "Protoss Marker", "Zerg Beacon", "Terran Beacon", "Protoss Beacon", "Zerg Flag Beacon", "Terran Flag Beacon", "Protoss Flag Beacon", "Dark Swarm", "Floor Hatch (UNUSED)", "Left Upper Level Door", "Right Upper Level Door", "Left Pit Door", "Right Pit Door", "Start Location", "Flag", "Psi Emitter", "Data Disc", "Khaydarin Crystal");

my @segments = (
	["Deaths", "Player 8", "Terran Vulture"],
	["Deaths", "Player 8", "Terran Goliath"],
	["Deaths", "Player 8", "Terran Marine"],
	["Deaths", "Player 8", "Terran SCV"],
	["Deaths", "Player 8", "Alan Schezar (Goliath)"],
	["Deaths", "Player 8", "Terran Ghost"],
	["Deaths", "Player 8", "Terran Wraith"],
	["Deaths", "Player 8", "Terran Science Vessel"],
	["Deaths", "Player 8", "Gui Montag (Firebat)"],
	["Deaths", "Player 8", "Terran Dropship"],
	["Deaths", "Player 8", "Terran Battlecruiser"],
	["Deaths", "Player 8", "Vulture Spider Mine"],
	["Deaths", "Player 8", "Terran Civilian"],
	["Deaths", "Player 8", "Sarah Kerrigan (Ghost)"],
	["Deaths", "Player 8", "Jim Raynor (Vulture)"],
	["Deaths", "Player 8", "Jim Raynor (Marine)"],
	["Deaths", "Player 8", "Tom Kazansky (Wraith)"],
	["Deaths", "Player 8", "Magellan (Science Vessel)"],
	["Deaths", "Player 8", "Edmund Duke (Siege Tank)"],
	["Deaths", "Player 8", "Edmund Duke (Siege Mode)"]		
);

my $currentSwitch = 1;

sub findMemorySegment {
	return @{shift(@segments)};
}

sub findUnkillableUnit {
	return ("Deaths", "Current Player", shift(@unkillable_units));
}

sub vars {
	my @maxs = @_; 
	my @rval = ();
	
	foreach my $max (@maxs) {
		if ($max == 1) {
			push @rval, Trigedit::Scalar->new( mem => ["Switch", ("Switch" . $currentSwitch)], max => 1 );
			$currentSwitch++;
		} else {
			push @rval, Trigedit::Scalar->new( mem => [findMemorySegment()], max => $max );
		}
	}
	
	return @rval;
}

1;
