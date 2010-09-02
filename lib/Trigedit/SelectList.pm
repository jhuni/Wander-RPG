package Trigedit::SelectList;

use Moose;
use boolean;
use Trigedit::Scalar;
use List::MoreUtils qw(first_index);

extends 'Trigedit::Scalar';

has 'list' => (
	is => 'rw'
);

sub eqn {
	my ($self, $arg) = @_;
	my @list = @{$self -> list()};
	
	$self == (first_index {$_ eq $arg} @list);
}

sub setn {
	my ($self, $arg) = @_;
	my @list = @{$self -> list()};
	
	$self -> set(first_index {$_ eq $arg} @list);
}

1;

