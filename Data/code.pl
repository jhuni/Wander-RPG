#!/usr/bin/perl
package main;

use strict;
use warnings;
use boolean;

use List::Util qw(min);
use File::Slurp;

# Use lib
use lib './lib';

# Trigedit Modules
use Trigedit::Scalar;
use Trigedit::Core qw(:std);
use Trigedit::Compiler::TextBackend;
use Trigedit::Memory;
use Map::Hero;

# General Purpose Utilities:
use Util::MapData;

# Import Data
require './Data/FontData.pm';

# Local Modules
use Map::Grid;
use Map::Font;
use Map::Menu::SelectionSystem;
use Map::Menu::Builder;
use Map::Units;
use Map::World;
use Map::Hero;

%Map::Font::font = getFont();

# Here is the variables:
my ($difficulty) = vars(3);
my $money = Trigedit::Scalar -> new(
	mem => ["Resource", "Player 1", "ore"]
);


# Here is a nice menu:
my @menu = (
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
);

my %events = (
	# Help menu
	"Help/Rundown" => [
		DisplayTextMessage("Always Display", "This game is an RPG where you travel the planet, fight battles, accumulate money, and purchase things.")
	],
	"Help/Battles" => [
		DisplayTextMessage("Always Display", "This game has a battle system with up to eight characters per battle. Battles are turn based similar to FF8.")
	],
	
	# Settings:
	"Cutscenes/Enable" => [
		DisplayTextMessage("Always Display", "Cut scenes enabled")
	],
	"Cutscenes/Disable" => [
		DisplayTextMessage("Always Display", "Cut scenes disabled")
	],
	
	"Difficulty/Easy" => [
		$difficulty -> set(1)
	],
	"Difficulty/Medium"	=> [
		$difficulty -> set(2)
	],
	"Difficulty/Hard" => [
		$difficulty -> set(3)
	],
	
	# Start Game:
	"Ok" => [
		MoveLocationXY(280, 420, "Hero"),
		CreateUnit("Player 1", "Terran Marine", 1, "Selection Area"),
		$Map::Hero::enableHero -> set(true),
		
		$Map::World::worldX -> set(6),
		$Map::World::worldY -> set(6),
		$Map::World::townBuiltYet -> set(false),
		
		$Map::Menu::Builder::currentMenu -> set(2),
		$Map::Menu::Builder::subMenu -> set(0),
		$Map::Menu::Builder::builtYet -> set(false),
		$Map::Font::strno -> set(0),
		
		$money -> add(50)
	]

);

# Now lets build that menu:
buildMenu(\@menu, \%events);

my @secondMenu = (
	{text => "Units"},
	{text => "Item"}
);

my %secondEvents = (
	"Item" => [
		DisplayTextMessage("Always Display", "Coming Soon")
	]
);

buildMenu(\@secondMenu, \%secondEvents);



# Here be the triggers:
my @triggers = (
	[
		["All Players"],
		PreserveTrigger(),
		createGridSystem(),
		createCharacterSystem(%Map::Font::font)
	],
	
	[
		["Player 1"],
		PreserveTrigger(),
		createSelectionSystem()
	],
	
	[
		["Player 7"],
		PreserveTrigger(),
		(map { Wait(0) } 0..314)
	],
	
	[
		["Player 8"],
		PreserveTrigger(),
		createMenuBuildSystem(),
		SetInvincibility("All players", "Any unit", "Anywhere", "enabled")
	]
	
);

push @triggers, [
	["Player 1"],
	
	{
		"if" => [],
		"then" => [
			RunAIScript("+Vi7"),
			$Map::Menu::Builder::currentMenu -> set(1),
			$Map::World::townBuiltYet -> set(true)
		]
	}
	
];







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

require './World/Towns/Start Town/Events.pm';
require './World/Houses/Stim House/Events.pm';

# Here is the world navigation system:
$Map::World::towns{'Regions'} = { Util::MapData::handleMap(read_file("./World/Map.txt")) };

push @Map::World::events, (
	{
		"if" => [
			CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'DecX'} } )
		],
		"then" => [
			$Map::World::worldX -> add(-1),
			$Map::World::townBuiltYet -> set(false)
		]
	},
	
	{
		"if" => [
			CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'IncX'} } )
		],
		"then" => [
			$Map::World::worldX -> add(1),
			$Map::World::townBuiltYet -> set(false)
		]
	},
	
	{
		"if" => [
			CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'DecY'} } )
		],
		"then" => [
			$Map::World::worldY -> add(-1),
			$Map::World::townBuiltYet -> set(false)
		]
	},
	
	{
		"if" => [
			CheckLocation( %{ $Map::World::towns{'Regions'}{'locations'}{'IncY'} } )
		],
		"then" => [
			$Map::World::worldY -> add(1),
			$Map::World::townBuiltYet -> set(false)
		]
	}
);

push @triggers, (
	[
		["Player 1"],
		PreserveTrigger(),
		
		{
			"if" => [
				$Map::World::townBuiltYet == false,
				$Map::World::worldX == 6,
				$Map::World::worldY == 6
			],
			"then" => [
				$Map::World::currentTown -> setn("Start Town")
			]
		},
		
		{
			"if" => [
				$Map::World::townBuiltYet == false,
				$Map::World::worldX == 7,
				$Map::World::worldY == 6
			],
			"then" => [
				$Map::World::currentTown -> setn("Zerg Town")
			]
		},
		
		{
			"if" => [
				$Map::World::townBuiltYet == false,
				$Map::World::worldX == 6,
				$Map::World::worldY == 5
			],
			"then" => [
				$Map::World::currentTown -> setn("Mountains")
			]
		},
		
		{
			"if" => [
				$Map::World::townBuiltYet == false,
				$Map::World::worldX == 5,
				$Map::World::worldY == 6
			],
			"then" => [
				$Map::World::currentTown -> setn("MountainsLong")
			]
		},
		
		@Map::World::buildAreas,
		
		heroScan(),
		@Map::World::events
		
	]
);








# Compile the triggers:
write_file("./output.txt", Trigedit::Compiler::TextBackend::compileTriggers(@triggers));





