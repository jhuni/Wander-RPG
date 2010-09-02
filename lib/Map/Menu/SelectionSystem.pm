package Map::Menu::SelectionSystem;

use strict;
use warnings;
use boolean;

use Trigedit::Scalar;
use Trigedit::Core qw(:std);
use Trigedit::Memory;

use Map::Font;
use Map::Units;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(createSelectionSystem createSelectorXY);

our ($selectedItem, $selectedMode) = vars(36, 3);

our @menuEvents = ();

my @players = ("Player 9", "Player 10", "Player 11", "Player 12");

my @units = (
	"Zerg Zergling",
	"Devouring One (Zergling)",
	"Zerg Hydralisk",
	"Hunter Killer (Hydralisk)",
	"Zerg Lurker",
	"Zerg Defiler",
	"Unclean One (Defiler)",
	"Infested Terran",
	"Zerg Drone"
);

sub createSelectorXY {
	my ($x, $y, $n) = @_;
	
	my $player = $players[int($n / 9)];
	my $unit = $units[$n%9];
	
	# Actions:
	MoveLocationXY($x, $y, "7x7");
	CreateUnit("Player 4", "Zerg Beacon", 1, "7x7");
	MoveLocation("Player 4", "Zerg Beacon", "7x7", "7x7");
	CreateUnit("Player 1", "Zerg Zergling", 1, "7x7");
	CreateUnitWithProperties("Player 4", $unit, 1, "7x7", 1);
	GiveUnitsToPlayer("Player 4", $player, $unit, "All", "7x7");
	MoveUnit($player, $unit, "All", "7x7", "7x7");
	
}

sub getActions {
	my ($n) = @_;
	
	my $player = $players[int($n / 9)];
	my $unit = $units[$n%9];
	
	If {
		$selectedItem == 0;
		Bring($player, $unit, "Selection Area", "At least", 1);
	} Then {
		MoveLocation($player, $unit, "Selection Area", "7x7");
		MoveLocation("Player 1", "Map Revealer", "7x7", "12x12");
		MoveLocation("Player 1", "Zerg Zergling", "7x7", "1x1 Pixel");
		MoveUnit("Player 4", "Terran Ghost", "All", "Anywhere", "1x1 Pixel");
		
		If {
			Bring("Player 4", "Terran Ghost", "1x1 Pixel", "Exactly", 1);
			Bring("Player 1", "Zerg Zergling", "7x7", "Exactly", 1);
		} Then {
			$selectedItem -> set($n+1);
			$selectedMode -> set(1);
		};
		
		If {
			Bring("Player 1", "Zerg Zergling", "7x7", "Exactly", 0);
		} Then {
			$selectedItem -> set($n + 1);
			$selectedMode -> set(2);
		};

	};
	
}



sub createSelectionSystem {

	# Create the ghost:
	If {
		Bring("Player 4", "Terran Ghost", "Anywhere", "Exactly", 0);
	} Then {
		CreateUnit("Player 4", "Terran Ghost", 1, "7x7");
	};
	
	getActions($_) for 0..35;
	
	RemoveUnit("Player 4", "Terran Ghost");
	
	# Menu Events
	foreach my $menuEvent (@menuEvents) {
		$menuEvent -> ();
	}
	
	If {
		$selectedMode > 0;
	} Then {
		$selectedMode -> set(0);
		$selectedItem -> set(0);
		RemoveUnitAtLocation("Player 1", "Zerg Zergling", "All", "12x12");
		CreateUnit("Player 1", "Zerg Zergling", 1, "7x7");
	};
	
}




1;
