package Util::MapData;

use strict;
use warnings;
use File::Slurp;

sub getBytes {
	my ($mapString) = @_;
	$mapString =~ s/\s+//g;
	
	my @bytes = ();
	
	# Get The Bytes
	foreach my $i (0..(length($mapString)/2)) {
		$bytes[$i] = hex(substr($mapString, $i*2,2)) . " ";
	}
	
	return @bytes;
}

sub handleInt {
	my @bytes = @_;
	
	my $rval = 0;
	
	foreach my $i (0..$#bytes) {
		$rval += $bytes[$i] * (256**$i);
	}
	
	return $rval;
}

sub handleUnit {
	my @bytes = @_;
	
	return (
		"x" => ($bytes[5]*256 + $bytes[4]),
		"y" => ($bytes[7]*256 + $bytes[6]),
		"uid" => ($bytes[9]*256 + $bytes[8]),
		"player" => ($bytes[16] + 1)
	);
	
}

sub handleMap {
	my ($mapString) = @_;
	
	my %map = ();
	my @bytes = getBytes($mapString);
	my $i = 0;

	while (1) {	
		my $sectionHeader = join '', map {chr $_} @bytes[$i..$i+3];
		my $sectionLength = handleInt(@bytes[$i+4..$i+7]);
		
		if ($sectionHeader eq "UNIT") {
			my @units = ();
			my @sectionBytes = @bytes[$i+8..$i+7+$sectionLength];
			
			my $n = 0;
			while (1) {
				push @units, {handleUnit(@sectionBytes[$n*36..($n+1)*36])};
				$n++;
				last if ($n+1)*36 > scalar(@sectionBytes);
			}
			
			$map{'units'} = \@units;
		}
		
		if ($sectionHeader eq "STR ") {
			my @sectionBytes = @bytes[$i+8..$i+7+$sectionLength];
			
			my $stringCount = handleInt(@sectionBytes[0..1]);
			my $i = $stringCount*2 + 3;
			my $str = join '', map {chr $_} @sectionBytes[$i..$#sectionBytes];
			my @strs = split chr(0), $str;
			
			$map{'strs'} = \@strs;
		}
		
		if ($sectionHeader eq "MRGN") {
			my @sectionBytes = @bytes[$i+8..$i+7+$sectionLength];
			my %locations = ();
			
			my $n = 0;
			while (1) {
				my @locationBytes = @sectionBytes[$n*20..($n+1)*20];

				my $startX = handleInt(@locationBytes[0..3]);
				my $startY = handleInt(@locationBytes[4..7]);
				my $endX = handleInt(@locationBytes[8..11]);
				my $endY = handleInt(@locationBytes[12..15]);
				my $name = $map{'strs'}[handleInt(@locationBytes[16..17])-1];
				
				$n++;
				last if ($n+1)*20 > scalar(@sectionBytes);
				next if $startX == 0 && $endX == 0;
				
				$locations{$name} = {
					"startx" => $startX,
					"starty" => $startY,
					"endx" => $endX,
					"endy" => $endY
				};
			}
			
			$map{'locations'} = \%locations;

		}
		
		$i += $sectionLength + 8;
		
		last if $i >= $#bytes;

	}
	
	return %map;
	
}

1;
