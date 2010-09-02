package Trigedit::Simplifier;

use strict;
use warnings;
use boolean;

use List::Util qw(min);
use List::MoreUtils qw(any);

sub PreserveTrigger {
	return {"id" => "PreserveTrigger", "args" => []};
}

sub Always {
	return {"id" => "Always", "args" => []};
}

# This should allow you to have any number of actions [0-6500*60] or so
# This should allow you to have any number of conditions [0-6500*15] or so
# This should allow you to embed if then statements in if statements.
sub simplifyIfStatement {
	my ($statementRef, $condRef, $preserve) = @_;
	my %statement = %{$statementRef};
	
	my @if = (@{$condRef}, @{$statement{'if'}});
	my @then = @{$statement{'then'}};
	
	# Just return @then if we don't need an if
	return @then if scalar(@if) == 0;
	
	# This is the maximum amount of triggers
	my $lim = $preserve ? 63 : 64;
	
	# Split the trigger up
	my @statements = ();
	my @consecutiveStatements = ();
	foreach my $statementNumber (0..$#then) {
		my %statement = %{ $then[$statementNumber] };
		
		push @consecutiveStatements, {%statement} if defined $statement{'id'};
		
		my $statementCount = scalar(@consecutiveStatements);
		if ($statementNumber == $#then || !defined $statement{'id'} || $statementCount == $lim) {
			push @statements, {
				"if" => [@if],
				"then" => [
					($preserve) ? PreserveTrigger() : (),
					@consecutiveStatements
				]
			} if $statementCount != 0;
			@consecutiveStatements = ();
		}
		
		if (!defined $statement{'id'}) {
			
			push @statements, simplifyIfStatement(\%statement, \@if, $preserve);
			
		}
		
	}
	
	return @statements;
	
}

# This handles the players part of things, and the basic trigger creation
sub simplifyTrigger {
	my @trigger = @_;
	
	my @players = @{$trigger[0]};
	my @statements = @trigger[1..$#trigger];
	
	# Determine if this is a preserve trigger
	my $preserve = true if (any {
		my %hsh = %{$_};
		defined $hsh{'id'} && $hsh{'id'} eq "PreserveTrigger";
	} @statements);
	
	# This is the maximum amount of triggers
	my $lim = $preserve ? 63 : 64;
	
	my @simplifiedStatements = ();
	foreach my $statementRef (@statements) {
		my %statement = %{ $statementRef };
	
		# We need to do something special for statements with ids and not of if/then
		if (defined $statement{'id'}) {
			next if $statement{'id'} eq "PreserveTrigger";
			push @simplifiedStatements, $statementRef;
		} else {
			push @simplifiedStatements, simplifyIfStatement(\%statement, [], $preserve);
		}
		
	}
	
	my @triggers = ();
	my @consecutiveStatements = ();
	foreach my $statementNumber (0..$#simplifiedStatements) {
		my %statement = %{ $simplifiedStatements[$statementNumber] };
		
		push @consecutiveStatements, {%statement} if defined $statement{'id'};
		
		my $statementCount = scalar(@consecutiveStatements);
		if ($statementNumber == $#simplifiedStatements || !defined $statement{'id'} || $statementCount == $lim) {
			push @triggers, [
				[@players],
				{
					"if" => [Always()],
					"then" => [
						($preserve) ? PreserveTrigger() : (),
						@consecutiveStatements
					]
				}
			] if $statementCount != 0;
			@consecutiveStatements = ();
		}
			
		if (!defined $statement{'id'}) {	
			push @triggers, [
				[@players],
				{%statement}
			];
		}
		
	}
	
	return @triggers;
	
}

1;