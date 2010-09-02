package Map::Hero;

use strict;
use warnings;
use boolean;

use Trigedit::Core qw(:std);
use Trigedit::Scalar;
use Trigedit::Memory;

use Map::Grid;
use Map::Units;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(CheckLocation heroScan moveHeroTo);

# Variables:
our ($heroX, $heroY, $enableHero) = vars(320, 464, 1);

# Coordinate detection:
sub heroScan {
	
	# Y scan
	If {
		$enableHero == true;
	} Then {
		$heroY -> set(1);
		MoveToY("Xsize", 0);
	};
	
	foreach my $y (1..464) {
		If {
			$heroY == $y;
			Bring("Player 1", "Terran Marine", "Xsize", "Exactly", 0);
		} Then {
			$heroY -> add(1);
			MoveToY("Xsize", $y);
			MoveToY("G0,0", $y);
		};
	}
	
	# X scan
	If {
		$enableHero == true;
	} Then {
		$heroX -> set(1);
		LocationChain("G0,0", "XShift", "G1,0");
	};
	
	foreach my $x (1..319) {
		If {
			$heroX == $x;
			Bring("Player 1", "Terran Marine", "G1,0", "Exactly", 0);
		} Then {
			$heroX -> add(1);
			LocationChain(getXLocations("Xshift", "G0,0", $x), "G1,0");
		};
	}
	
	# Follow locations
	If {
		$enableHero == true;
	} Then {
		MoveLocation("Player 1", "Terran Marine", "Anywhere", "7x7");
	};

}

sub CheckLocation {
	my %location = @_;
	
	# Conditions:
	$heroX >= int( ($location{'startx'}-768) / 8 );
	$heroX <= int( ($location{'endx'}-768)   / 8 );
	$heroY >= int( ($location{'starty'}-192) / 8 );
	$heroY <= int( ($location{'endy'}-192)   / 8 );
}

sub moveHeroTo {
	my %location = @_;

	my $x = int( ($location{'startx'}-768) / 8);
	my $y = int( ($location{'starty'}-192) / 8);
	
	# Actions:
	MoveLocationXY($x, $y, "G0,0");
	MinimapPing("G0,0");
	MoveUnit("Player 1", "Terran Marine", "All", "Anywhere", "G0,0");
	CenterView("G0,0");
}

1;