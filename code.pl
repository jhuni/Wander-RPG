#!/usr/bin/perl
package main;

use strict;
use warnings;
use boolean;

use List::Util qw(min);
use File::Slurp;

# Use lib:
use lib './lib';

# Trigedit Modules
use Trigedit::Core qw(:std);
use Trigedit::Simplifier;
use Trigedit::Compiler::TextBackend;
use Trigedit::Scalar;
use Trigedit::Memory;
use Trigedit::SelectList;
use Trigedit::UnitArray;

# General Purpose Utilities:
use Util::MapData;

# Import Data
require './Data/FontData.pm';

# Local Modules
use Map::Grid;
use Map::Font;
use Map::Units;
use Map::Menu::SelectionSystem;
use Map::Menu::Builder;
use Map::World;
use Map::Hero;

# Necessary data:
%Map::Font::font = getFont();

my ($difficulty, $enableScenes) = vars(3, 1);

# Here is a nice menu:
buildMenu("Start Menu", [

	{text => 'Help', children => [
		{text => 'Rundown'},
		{text => 'Battles'},
		{text => 'Menus'},
		{text => 'World'}
	]},
	{text => 'Cutscenes', children => [
		{text => 'Enable'},
		{text => 'Disable'}
	]},
	{text => 'Difficulty', children => [
		{text => 'Easy'},
		{text => 'Medium'},
		{text => 'Hard'}
	]},
	{text => 'Ok'}
	
], {
	# Help menu
	"Help/Rundown" => Then {
		DisplayTextMessage("Always Display", "This game is an RPG where you travel the planet, fight battles, accumulate money, and purchase things.")
	},
	"Help/Battles" => Then {
		DisplayTextMessage("Always Display", "This game has a battle system with up to eight characters per battle. Battles are turn based similar to FF8.")
	},
	
	# Settings:
	"Cutscenes/Enable" => Then {
		$enableScenes -> set(true);
	},
	"Cutscenes/Disable" => Then {
		$enableScenes -> set(false);
	},
	
	"Difficulty/Easy" => Then {
		$difficulty -> set(1);
	},
	"Difficulty/Medium"	=> Then {
		$difficulty -> set(2);
	},
	"Difficulty/Hard" => Then {
		$difficulty -> set(3);
	},
	
	# Start Game:
	"Ok" => Then {
		CreateUnit("Player 1", "Terran Marine", 1, "Selection Area");
		MoveLocationXY(280, 420, "Hero");
		$Map::Hero::enableHero -> set(true);
		
		$Map::World::worldX -> set(6);
		$Map::World::worldY -> set(6);
		$Map::World::townBuiltYet -> set(false);
		
		$Map::Menu::Builder::currentMenu -> setn("Main Menu");
		$Map::Menu::Builder::subMenu -> set(0);
		$Map::Menu::Builder::builtYet -> set(false);
		$Map::Font::strno -> set(0);
	}
});

buildMenu("Main Menu", [
	{text => "Units"},
	{text => "Item"}
], {
	"Item" => Then {
		DisplayTextMessage("Always Display", "Coming Soon")
	}
}); ## END MENU ##



###############################
# Here we are going to create a town
###############################

sub getHouse {
	my ($houseName) = @_;
	
	my %map = Util::MapData::handleMap(read_file("./World/Houses/$houseName/Map.txt"));
	registerHouse($houseName, \%map);
}

sub getTown {
	my ($townName) = @_;
	
	my %map = Util::MapData::handleMap(read_file("./World/Towns/$townName/Map.txt"));
	registerTown($townName, \%map);
}

# Here is the world navigation system:
$Map::World::towns{'Regions'} = { Util::MapData::handleMap(read_file("./World/Map.txt")) };

getTown("Start Town");
getTown("Zerg Town");
getTown("Mountains");
getTown("MountainsLong");

getHouse("Stim House");
getHouse("House1");
getHouse("House2");
getHouse("Hospital");
getHouse("Equipment");
getHouse("Weapons");

# Here we do some business:
my ($init) = vars(1);

sub init {
	If {
		$init == false;
	} Then {
		RunAIScript("+Vi7");
		$Map::Menu::Builder::currentMenu -> setn("Start Menu");
		$Map::Menu::Builder::subMenu -> set(0);
		$init -> set(true);
	};
}

sub worldNavigation {

	If {
		$Map::World::townBuiltYet == false
	} Then {
		
		If {
			$Map::World::worldX == 6,
			$Map::World::worldY == 6
		} Then {
			$Map::World::currentTown -> setn("Start Town")
		}
		
		If {
			$Map::World::worldX == 7,
			$Map::World::worldY == 6
		} Then {
			$Map::World::currentTown -> setn("Zerg Town")
		}
		
		If {
			$Map::World::worldX == 6,
			$Map::World::worldY == 5
		} Then {
			$Map::World::currentTown -> setn("Mountains")
		}
		
		If {
			$Map::World::worldX == 5,
			$Map::World::worldY == 6
		} Then {
			$Map::World::currentTown -> setn("MountainsLong")
		}		
	};

	foreach my $event (@Map::World::buildAreas) { 
		$event -> ();
	}
	
}

sub mapBoundaries {

	If {
		CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'DecX'} } )
	} Then {
		$Map::World::worldX -> add(-1),
		$Map::World::townBuiltYet -> set(false)
	};
	
	If {
		CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'IncX'} } )
	} Then {
		$Map::World::worldX -> add(1),
		$Map::World::townBuiltYet -> set(false)	
	};

	If {
		CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'DecY'} } )
	} Then {
		$Map::World::worldY -> add(-1),
		$Map::World::townBuiltYet -> set(false)	
	};
	
	If {
		CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'IncY'} } )	
	} Then {
		$Map::World::worldY -> add(1),
		$Map::World::townBuiltYet -> set(false)	
	};
	
}

sub main {
	
	Trigger("Player 1");
	PreserveTrigger();
	init();
	createSelectionSystem();
	heroScan();
	require './World/Towns/Start Town/Events.pm';
	require './World/Houses/Stim House/Events.pm';
	mapBoundaries();
	worldNavigation();
	createMenuBuildSystem();
	
	Trigger("Player 7");
	PreserveTrigger();
	Wait(0) for 0..314;
	
	Trigger("Player 8");
	PreserveTrigger();
	SetInvincibility("All players", "Any unit", "Anywhere", "enabled");
	
	Trigger("All Players");
	PreserveTrigger();
	createGridSystem();
	createCharacterSystem(%Map::Font::font);
	
}

# Compilation stage:
main();
write_file("./output.txt", Trigedit::Compiler::TextBackend::compileTriggers(@Trigedit::Core::triggers));




1;