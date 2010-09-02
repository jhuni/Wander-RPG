package Map::World;

use strict;
use warnings;
use boolean;

use Trigedit::Core qw(:std);
use Trigedit::Scalar;
use Trigedit::SelectList;
use Trigedit::Memory;

use Map::Grid;
use Map::Units;
use Map::Hero;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(registerHouse registerTown moveToHouse);

# Here is the world variables:
our ($worldX, $worldY) = vars(500, 500);

# Here is the town:
our $currentTown = Trigedit::SelectList->new(
	mem => [Trigedit::Memory::findMemorySegment()],
	list => ["undef"]
);

# Here is the house:
our $currentHouse = Trigedit::SelectList->new(
	mem => [Trigedit::Memory::findMemorySegment()],
	list => ["undef"]
);

our ($townBuiltYet, $houseBuiltYet) = vars(1, 1);

# Here is some extra data:
our %towns = ();
our %houses = ();
our @buildAreas = ();

sub registerHouse {
	my ($houseName, $mapRef) = @_;
	my %map = %{$mapRef};
	
	push @{$currentHouse->list()}, $houseName;
	$houses{$houseName} = \%map;
	
	push @buildAreas, Then {
	
		If {
			$currentHouse -> eqn($houseName);
			$houseBuiltYet == false;
		} Then {
			createMapUnits(%map);
			moveHeroTo( %{$map{'locations'}{'Hero'}} );
			$houseBuiltYet -> set(true);
		};
		
	};

}

sub moveToHouse {
	my ($houseName) = @_;
	
	$currentHouse -> setn($houseName);
	$houseBuiltYet -> set(false);
}

sub registerTown {
	my ($townName, $mapRef) = @_;
	my %map = %{$mapRef};
	
	push @{$currentTown->list()}, $townName;
	$towns{$townName} = \%map;
	
	push @buildAreas, Then {
		If {
			$currentTown -> eqn($townName);
			$townBuiltYet == false;
		} Then {
			MoveUnit("Player 1", "Terran Marine", "All", "Anywhere", "Selection Area");
			RemoveUnitAtLocation("All players", "Any unit", "All", "Town");
			MoveUnit("Player 1", "Terran Marine", "All", "Anywhere", "Hero");
			CenterView("Hero");
			createMapUnits(%map);
			$townBuiltYet -> set(true);
		};
	};

}

1;