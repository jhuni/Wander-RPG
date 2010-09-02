package Map::Menu::Builder;

use strict;
use warnings;
use boolean;

use Trigedit::Scalar;
use Trigedit::Core qw(:std);
use Trigedit::Memory;

use Map::Font;
use Map::Units;
use Map::Menu::SelectionSystem;

# Exportation:
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(createMenuBuildSystem buildMenu);

# Variables:
our @buildActions = ();
our $currentMenu = Trigedit::SelectList->new(
	mem => [Trigedit::Memory::findMemorySegment()],
	max => 127,
	list => ["undef"]
);

our ($subMenu, $builtYet) = vars(127, 1);
my $strno = $Map::Font::strno;
my $menuIndex = 1;

sub checkMenu {
	my @positions = @_;
	
	foreach my $i (0..$#positions) {
		if ($i == 0) {
			$currentMenu == $positions[$i];
		} elsif ($i == 1) {
			$subMenu == $positions[$i];
		}
	}
	
}

sub drawMenu {
	my ($x, $y, $sel, $menuRef, @menuCheckArgs) = @_;
	
	If {
		checkMenu(@menuCheckArgs);
		$strno == scalar(@menuCheckArgs);
		$Map::Font::isDrawing == false;
		$builtYet == false;
	} Then {
		my @lines = map { my %menu = %{$_}; $menu{'text'}; } @{$menuRef};
		my $str = join "\n", @lines;
		
		# Print the string onto the map:
		printString($x, $y, $str);
	
		# Create selectors:
		foreach my $i (0..$#lines) {
			my $cx = $x + Map::Font::getWordLength(\%Map::Font::font, $lines[$i]);
			my $cy = $y + (10 * $i);
			
			createSelectorXY($cx + 10, $cy + 5, $sel + $i);
		}
		
		# Center View Business:
		if (scalar(@menuCheckArgs) > 1) {
			MoveLocationXY($x + 28, $y + 22, "G0,0");
			CenterView("G0,0");
		}
		
	};
		
}

sub drawSubMenu {
	my ($i, $subMenuNumber, @menuCheckArgs) = @_;
	
	return Then {
		If {
			checkMenu(@menuCheckArgs);
			$Map::Menu::SelectionSystem::selectedItem == $i;
		} Then {
			$subMenu -> set($subMenuNumber);
			$builtYet -> set(false);
			$strno -> set(0);
		};
	};
}

sub createMenu {
	# Arguments:
	my ($i, $currentText, $menuCheckArgsRef, $eventsRef, $menuRef) = @_;
	my @menu = @{$menuRef};
	my @menuCheckArgs = @{$menuCheckArgsRef};
	my %events = %{$eventsRef};
	
	# New Actions 
	my $t = $i+0;
	my @actions = ( Then {
		drawMenu(5 + 85 * $#menuCheckArgs, 5, $t, \@menu, @menuCheckArgs);
	} );
	
	my $subMenuNumber = 1;
	foreach my $menuItemRef (@menu) {
		my %menuItem = %{ $menuItemRef };
		$i++;
		
		# Get the text:
		my $itemText = $currentText;
		$itemText .= '/' if $itemText ne '';
		$itemText .= $menuItem{'text'};
		
		if (defined $menuItem{'children'}) {
			# Here we do the event:
			my ($t, $smn) = ($i+0, $subMenuNumber+0);
			push @Map::Menu::SelectionSystem::menuEvents, drawSubMenu($i, $subMenuNumber, @menuCheckArgs);
			
			# Now we do some recursion:
			my @children = @{ $menuItem{'children'} };
			
			push @menuCheckArgs, $subMenuNumber;
			push @actions, createMenu(scalar(@menu), $itemText, \@menuCheckArgs, \%events, \@children); 
			pop @menuCheckArgs;
			
			$subMenuNumber++;
		} else {
			next if !defined $events{$itemText};
			my $event = $events{$itemText};
			
			my $t = $i+0;
			push @Map::Menu::SelectionSystem::menuEvents, Then {
				If {
					checkMenu(@menuCheckArgs);
					$Map::Menu::SelectionSystem::selectedItem == $t;
				} Then {
					$event -> ();
				};
			};
		}
				
	}
	
	return @actions;
}

sub buildMenu {
	my ($menuName, $menuRef, $eventsRef) = @_;
	my @cm = ($menuIndex);
	
	push @{$currentMenu->list()}, $menuName;
	push @buildActions, createMenu(0, '', \@cm, $eventsRef, $menuRef);
	
	$menuIndex++;
}

sub createMenuBuildSystem {

	If {
		$builtYet == false;
		$strno == 0;
	} Then {
		$strno -> add(1);
		RemoveUnitAtLocation("All players", "Any unit", "All", "Selection Area");
	};
	
	# Build Actions:
	foreach my $buildAction (@buildActions) {
		$buildAction -> ();
	}
	
	If {
		$Map::Font::isDrawing == false,
		$builtYet == false
	} Then {
		$builtYet -> set(true);
	};

}

1;