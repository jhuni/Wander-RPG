package main;

use strict;
use warnings;
use boolean;

my %map = %{ $Map::World::towns{'Start Town'} };

sub createHousesByLocs {
	my @towns = @_;
	
	foreach my $town (@towns) {
		If {
			CheckLocation(%{ $map{'locations'}{$town} });
		} Then {
			moveToHouse($town);
		}
	}
	
}

If {
	$Map::World::currentTown -> eqn("Start Town");
} Then {
	
	# Move Houses:
	If {
		$Map::World::currentHouse == 0;
	} Then {
		
		createHousesByLocs("Stim House", "House1", "House2", "Hospital", "Weapons", "Equipment");
		
	};
	
	If {
		CheckLocation(%{ $map{'locations'}{'Person1'} });
	} Then {
		Transmission("Always Display", "Welcome to Ebanon. You should be safe here.", "Terran Civilian", "7x7", "Set To", 2000, 'sound\\\\Misc\\\\Transmission.wav', 0);
	};
	
	If {
		CheckLocation(%{ $map{'locations'}{'Person2'} });
	} Then {
		Transmission("Always Display", "I noticed you are moving slowly. Go see the person in the house to the left, he can help you with that.", "Terran Civilian", "7x7", "Set To", 2500, 'sound\\\\Misc\\\\Transmission.wav', 0);
	};
	
	If {
		CheckLocation(%{ $map{'locations'}{'Person3'} });
	} Then {
		Transmission("Always Display", "I got my mind on my minerals, my minerals on my mind.", "Terran Civilian", "7x7", "Set To", 2500, 'sound\\\\Misc\\\\Transmission.wav', 0);	
	};
	
	If {
		CheckLocation(%{ $map{'locations'}{'Person4'} });
	} Then {
		Transmission("Always Display", "There is nice weather today, at least for Ana VI.", "Terran Civilian", "7x7", "Set To", 2500, 'sound\\\\Misc\\\\Transmission.wav', 0);	
	};
	
};


1;