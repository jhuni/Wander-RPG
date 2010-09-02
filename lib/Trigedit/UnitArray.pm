package Trigedit::UnitArray;

use Moose;
use boolean;
use Trigedit::Core qw(:all);
use List::MoreUtils qw(any);

has 'player' => (
	is => 'rw',
	isa => 'Str',
	default => 'All players'
);

has 'unit' => (
	is => 'rw',
	isa => 'Str',
	default => 'Any unit'
);

has 'location' => (
	is => 'rw',
	isa => 'Str',
	default => "Anywhere"
);

extends 'Trigedit::Scalar';

sub move {
	my ($self, $location, $amount) = @_;
	
	MoveUnit($self->player(), $self->unit(), $amount, $self->location(), $location);
}

sub give {
	my ($self, $player, $amount) = @_;
	
	GiveUnitsToPlayer($self->player(), $player, $self->unit(), $amount, $self->location());
}

sub order {
	my ($self, $order, $location) = @_;
	
	Order($self->player(), $self->unit(), $self->location(), $location, $order);
}

sub kill {
	my ($self, $amount) = @_;
	
	KillUnitAtLocation($self->player(), $self->unit(), $amount, $self->location());
}

sub remove {
	my ($self, $amount) = @_;
	
	RemoveUnitAtLocation($self->player(), $self->unit(), $amount, $self->location());
}

# Hp, Ep, Sp, Res, Hangar, Flags
sub setProps {
	my ($self, $propsRef, $amount) = @_;
	my ($player, $location, $unit) = ($self->player(), $self->location(), $self->unit());
	my %props = %{$propsRef};
	
	# Modify properties functions:
	ModifyUnitHitPoints($player, $unit, $props{'hp'}, $amount, $location) if defined $props{'hp'};
	ModifyUnitEnergy($player, $unit, $props{'hangar'}, $amount, $location) if defined $props{'hangar'};
	ModifyUnitShieldPoints($player, $unit, $props{'sp'}, $amount, $location) if defined $props{'sp'};
	ModifyUnitHangerCount($player, $unit, $props{'hangar'}, $amount, $location) if defined $props{'hangar'};
	ModifyUnitResourceAmount($player, $unit, $props{'res'}, $location) if defined $props{'res'};	
	
	# States
	SetInvincibility($player, $unit, $location, $props{'invincibility'}) if defined $props{'invincibility'};
	SetDoodadState($player, $unit, $location, $props{'doodad'}) if defined $props{'doodad'};
	
}



1;