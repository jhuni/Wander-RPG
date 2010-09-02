package Map::Font;

use strict;
use warnings;
use boolean;

use Trigedit::Scalar;
use Trigedit::Core qw(:std);
use Trigedit::Memory;
use Map::Grid;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(createCharacterSystem printString);

# Here are the primary variables in which I am involved with:
our ($isDrawing, $font_char, $currentTempChar, $strno, $lineStartX, $tempLineStartX) = vars(1, 127, 127, 255, 320, 320);

# Here are some interesting temp character variables in the form of arrays:
my @tempChars = (
Trigedit::Scalar->new( mem => ["Deaths", "Current Player", "Map Revealer"]),
Trigedit::Scalar->new( mem => ["Deaths", "Current Player", "Terran Beacon"]),
Trigedit::Scalar->new( mem => ["Deaths", "Current Player", "Zerg Beacon"]),
Trigedit::Scalar->new( mem => ["Deaths", "Current Player", "Protoss Beacon"]),
Trigedit::Scalar->new( mem => ["Deaths", "Current Player", "Terran Flag Beacon"])
);

my @temp_chars = (
Trigedit::Scalar->new( mem => ["Deaths", "Current Player", "Map Revealer"]),
Trigedit::Scalar->new( mem => ["Deaths", "Player 1", "Map Revealer"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 2", "Map Revealer"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 3", "Map Revealer"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 4", "Map Revealer"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 5", "Map Revealer"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 6", "Map Revealer"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 7", "Map Revealer"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 8", "Map Revealer"] ),
	
Trigedit::Scalar->new( mem => ["Deaths", "Player 1", "Terran Beacon"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 2", "Terran Beacon"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 3", "Terran Beacon"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 4", "Terran Beacon"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 5", "Terran Beacon"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 6", "Terran Beacon"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 7", "Terran Beacon"] ),
Trigedit::Scalar->new( mem => ["Deaths", "Player 8", "Terran Beacon"] )
);

# Non-code related utilities:
sub getWordLength {
	my ($fontRef, $str) = @_;
	
	my %font = %{$fontRef};
	
	my @chars = split '', $str;
	my $length = 0;
	
	foreach my $char (@chars) {
		my @letterData = @{ $font{$char} };
		$length += $letterData[1] + 2;
	}
	
	return $length;
}

sub combineBytes {
	my @chars = @_;
	my $rval = 0;
	
	foreach my $i (0..$#chars) {
		$rval += ($chars[$i] << ($i * 7));
	}
	
	return $rval;
}

sub setupString {
	my @chars = reverse split('', shift);
	
	return combineBytes(map { ord $_ } @chars);
}

sub doString {
	my ($str) = @_;
	my @chars = split('', $str);
	push @chars, chr(3);
	my @rstrs = '' x 8;
	
	for my $i (0..$#chars) {
		my $player = (8 * int($i / 32));
		$rstrs[$i % 8 + $player] .= $chars[$i];
	}
	
	my @rval = ();
	for my $ri (0..$#rstrs) {
		push @rval, $temp_chars[$ri+1] -> set(setupString($rstrs[$ri]))
	}
	return @rval;
		
}

sub printString {
	
	my ($x, $y, $str) = @_;

	my @statements = ();
	
	push @statements, (
		$isDrawing -> set(true),
		$Map::Grid::x -> set($x),
		$Map::Grid::y -> set($y),
		$lineStartX -> set($x),
		doString($str)
	);
	
	return @statements;
	
}

sub transferCharacters {
	
	my $i = 20;
	for my $dc (@tempChars) {
		foreach my $tchar (reverse(0..3)) {
			If {
				$currentTempChar == 0;
				$dc >= ( 2 ** (7*$tchar) );
			} Then {
				$currentTempChar -> set($i);
			};
			$i--;
		}
	}
	
	$i = 20;
	for my $dc (@tempChars) {
		foreach my $tchar (reverse(0..3)) {
			foreach (reverse(0..6)) {
				my $bit = 2**( $tchar*7 + $_ );
				
				If {
					$currentTempChar == $i;
					$dc >= ($bit);
				} Then {
					$dc -> subtract($bit);
					$font_char -> add( 2**$_ );
				};
				
			}
			$i--;
		}
	}

	return;
	
}



sub createCharacterSystem {
	my %font = @_;
	
	transferCharacters();
	
	for my $letter (32, 48..57, 65..90, 97..122) { 
		If {
			$font_char == $letter;
		} Then {
			# Letter Data:
			my @letterData = @{ $font{chr($letter)} };
			my $char = $letterData[0];
			my $width = $letterData[1];
			
			my @pixels = split '', (join '', split(/\n/, $char));
			
			foreach my $y (0..6) {
				foreach my $x (0..6) {
					my $i = ($y * 7) + $x;
					
					if ($pixels[$i] eq "1") {
						CreateUnitWithProperties("Player 8", "Devouring One (Zergling)", 1, "G$x,$y", 1);
					}
					
				}
			}
			
			$Map::Grid::x -> add($width+2);
		};
	}
	
	# End of text character:
	If {
		$font_char == 3;
	} Then {
		$strno -> add(1);
		$isDrawing -> set(false);
		$Map::Grid::x -> set(0);
		$Map::Grid::y -> set(0);
	};
	
	# New line character:
	If {
		$font_char == 10;
	} Then {
		$Map::Grid::y -> add(10);
		$Map::Grid::x -> set(0);
		$tempLineStartX -> set(0);
		$lineStartX -> transfer($Map::Grid::x, $tempLineStartX);
		$tempLineStartX -> transfer($lineStartX);
	};
	
	# Cleanup:
	$currentTempChar -> set(0);
	$font_char -> set(0);
	
}

1;