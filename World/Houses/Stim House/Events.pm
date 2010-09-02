package main;

use strict;
use warnings;
use boolean;

my %map = %{ $Map::World::houses{'Stim House'} };

If {
	$Map::World::currentHouse -> eqn('Stim House');
} Then {

	If {
		CheckLocation(%{ $map{'locations'}{'Exit'} });
	} Then {
		DisplayTextMessage("Always Display", "Still working on an exit system.");
	}

	If {
		CheckLocation(%{ $map{'locations'}{'Stim Man'} });
	} Then {
		Transmission("Always Display", "I have been researching biotechnology for the past twenty years. Recently I have perfected an implant which can double your movement speed with no negative side effects. I will sell one of these to you for 50 minerals.", "Terran Civilian", "7x7", "Set To", 3000, 'sound\\\\Misc\\\\Transmission.wav', 0);
	}
	
};

1;