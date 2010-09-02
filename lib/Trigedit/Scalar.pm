package Trigedit::Scalar;

use Moose;
use boolean;

use Trigedit::Core qw(:all);

has 'mem' => (
	is => 'rw'
);

has 'max' => (
	is => 'rw',
	isa => 'Int',
	default => (2**32)-1
);

has 'min' => (
	is => 'rw',
	isa => 'Int',
	default => 0
);

use overload '==' => \&_eq, fallback => 1;
use overload '>' => \&_gt, fallback => 1;
use overload '<' => \&_lt, fallback => 1;
use overload '>=' => \&_ge, fallback => 1;
use overload '<=' => \&_le, fallback => 1;
use overload '+=' => \&add, fallback => 1;
use overload '-=' => \&subtract, fallback => 1;

sub _mod {
	my ($self, $mod, $arg) = @_;
	my @mem = @{$self->mem()};
	my $max = $self->max();
	my $min = $self->min();
	my $range = $max - $min;
	my $isAction = $mod eq "Set To" || $mod eq "Add" || $mod eq "Subtract";
	my $isCondition = !$isAction;
	
	if ($mod eq "Subtract" || $mod eq "Add") {
		if ($arg >= $range) {
			$arg = ($mod eq "Subtract") ? $min : $max;
			$mod = "Set To";
		}
	} elsif ($mod eq "Set To") {
		$arg = $max if $arg > $max;
		$arg = $min if $arg < $min;
	}
	
	return if $mod eq "At least" && $arg <= $min;
	return if $mod eq "At most" && $arg >= $max;
	
	return Never() if $mod eq "At least" && $arg > $max;
	return Never() if $mod eq "At most" && $arg < $min;
	
	return Never() if $mod eq "Exactly" && ($arg > $max || $arg < $min);
	
	my $id = $mem[0];
	
	# Switches:
	if ($id eq "Switch") {
		Switch($mem[1], ($arg) ? "set" : "not set") if $isCondition;
		SetSwitch($mem[1], ($arg) ? "set" : "clear") if $isAction;
	}
	
	# Deaths:
	if ($id eq "Deaths") {
		Deaths($mem[1], $mem[2], $mod, $arg) if $isCondition;
		SetDeaths($mem[1], $mem[2], $mod, $arg) if $isAction;
	}
	
	# Resources:
	if ($id eq "Resource") {
		Accumulate($mem[1], $mod, $arg, $mem[2]) if $isCondition;
		SetResources($mem[1], $mod, $arg, $mem[2]) if $isAction;
	}
	
	# Score:
	if ($id eq "Score") {
		Score($mem[1], $mem[2], $mod, $arg) if $isCondition;
		SetScore($mem[1], $mod, $arg, $mem[2]) if $isAction;
	}
	
	# Timer:
	if ($id eq "Timer") {
		CountdownTimer($mod, $arg) if $isCondition;
		SetCountdownTimer($mod, $arg) if $isAction;
	}
	
	# Elapsed Time:
	if ($id eq "ElapsedTime") {
		ElapsedTime($mod, $arg) if $isCondition;
		die "Cannot write to read only variable Elapsed Time" if $isAction;
	}
	
	# Opponents:
	if ($id eq "Opponents") {
		Opponents($mem[1], $mod, $arg) if $isCondition;
		die "Cannot write to read only variable Opponents" if $isAction;
	}
	
	# Unit:
	if ($id eq "Unit") {
		Bring($mem[1], $mem[2], $mem[3], $mod, $arg) if $isCondition;
	}
	
	
	return;
	
}

sub _eq {
	my ($self, $arg) = @_;
	
	return $self->_mod("Exactly", $arg);
}

sub _gt {
	my ($self, $arg) = @_;
	
	return $self->_mod("At least", $arg + 1);
}

sub _lt {
	my ($self, $arg) = @_;
	
	return $self->_mod("At most", $arg - 1);
}

sub _ge {
	my ($self, $arg) = @_;
	
	return $self->_mod("At least", $arg);
}

sub _le {
	my ($self, $arg) = @_;
	
	return $self->_mod("At most", $arg);
}

sub add {
	my ($self, $addend) = @_;
	my $op = ($addend > 0) ? "Add" : "Subtract";
	$addend *= -1 if $addend < 0;
	
	return if $addend == 0;
	return $self->_mod($op, $addend);
}

sub subtract {
	my ($self, $addend) = @_;
	
	return $self->add(-$addend);
}

sub set {
	my ($self, $arg) = @_;
	
	return $self->_mod("Set To", $arg);	
}

sub countoff {
	my ($self, $arity) = @_;
	my $triggers = int(log($self->max()) / log($arity));
	my @rval = ();
	
	foreach my $i (0..$triggers) {
		unshift @rval, ($arity ** $i);
	}

	return @rval;
}

sub transfer {
	my ($self, @transferTo) = @_;

	my @nums = $self->countoff(2);
	
	foreach my $num (@nums) {
		If {
			$self >= $num;
		} Then {
			$self -> subtract($num);
			foreach my $var (@transferTo) {
				$var -> add($num);
			}
		};
	}
	
}

1;