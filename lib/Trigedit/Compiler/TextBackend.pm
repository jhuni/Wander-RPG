package Trigedit::Compiler::TextBackend;

use strict;
use warnings;
use boolean;

use List::MoreUtils qw(any);

# Trigedit modules
use Trigedit::Simplifier;

# This is for identifiers
use String::CamelCase;

our @QUOTED_TYPES = ("unit", "specific_unit", "player", "location", "text", "wav_text", "switch", "ai_script");

# This function will convert from the id to the trigedit function name
sub identifierToSource {
	my ($id) = @_;
	
	my @words = String::CamelCase::wordsplit($id);
	
	foreach my $i (0..$#words) {
			$words[$i] = "with" if $words[$i] eq "With";
			$words[$i] = "the" if $words[$i] eq "The";
	}
	
	return join " ", @words;
}

# This function will convert a statement to its trigedit source code
sub statementToSource {
	my %statementData = @_;
	
	# This is for the special case that the statementdata is undefined:
	return if !defined $statementData{'id'};
	
	# This is data specific to this statement
	my $id = $statementData{'id'};
	my @args = @{ $statementData{'args'} };
	
	# This is the static info that is related to this statement
	my %staticInfo = %{$Trigedit::Core::statements{$id}};
	my $subName = identifierToSource($id);
	my @argTypes = @{$staticInfo{'args'}};

	foreach my $i (0..$#argTypes) {
		$args[$i] = '"' . $args[$i] . '"' if any {$_ eq $argTypes[$i]} @QUOTED_TYPES;
	}
	
	return "$subName(" . (join ", ", @args) . ");";
	
}

# This function will convert a legal statement to its trigedit source code
sub triggerToSource {

	my @trigger = @_;
	
	my @players = @{$trigger[0]};
	my @if   = map { statementToSource(%{$_}) } @{$trigger[1]{'if'}};
	my @then = map { statementToSource(%{$_}) } @{$trigger[1]{'then'}};
	
	my $conditions = join "\n\t", @if;
	my $actions    = join "\n\t", @then;
	
	my $players = '"' . (join '","', @players) . '"';
	
my $rval = <<CODE;
Trigger($players){
Conditions:
	$conditions

Actions:
	$actions
}

//-----------------------------------------------------------------//

CODE

	return $rval;
	
}

sub compileTriggers {
	my @triggers = @_;
	my @simplifiedTriggers;
	
	for my $trigger (@triggers) {
		push @simplifiedTriggers, Trigedit::Simplifier::simplifyTrigger(@{$trigger});
	}
	
	my $rval = "";
	$rval .= triggerToSource(@{$_}) foreach @simplifiedTriggers;
	return $rval;
	
}

1;