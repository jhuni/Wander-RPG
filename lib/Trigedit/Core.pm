package Trigedit::Core;

use strict;
use warnings;
use List::MoreUtils qw(none);

use Exporter;

our @ISA = qw(Exporter);

# Conditions end with Switch
our %EXPORT_TAGS = (
	"all" => [
		qw(Accumulate Always Bring Command CommandTheLeast CommandTheLeastAt CommandTheMost CommandTheMostAt CountdownTimer Deaths ElapsedTime HighestScore Kill LeastKills LeastResources LeastScore MostKills MostResources Never Opponents Score Switch CenterView Comment CreateUnit CreateUnitWithProperties Defeat DisplayTextMessage Draw GiveUnitsToPlayer KillUnit KillUnitAtLocation LeaderBoardControlAtLocation LeaderBoardControl LeaderboardGreed  LeaderBoardKills LeaderBoardPoints LeaderBoardResources LeaderboardComputerPlayers LeaderboardGoalControlAtLocation LeaderboardGoalControl LeaderboardGoalKills LeaderboardGoalPoints LeaderboardGoalResources MinimapPing ModifyUnitEnergy ModifyUnitHangerCount ModifyUnitHitPoints ModifyUnitResourceAmount ModifyUnitShieldPoints MoveLocation MoveUnit MuteUnitSpeech Order PauseGame PauseTimer PlayWAV PreserveTrigger RemoveUnit RemoveUnitAtLocation RunAIScript RunAIScriptAtLocation SetAllianceStatus SetCountdownTimer SetDeaths SetDoodadState SetInvincibility SetMissionObjectives SetNextScenario SetResources SetScore SetSwitch TalkingPortrait Transmission UnmuteUnitSpeech UnpauseGame UnpauseTimer Victory Wait Trigger If Then)
	]
);

@{$EXPORT_TAGS{'std'}} = grep { 
	my $item = $_;
	none {$_ eq $item} qw(Always Never Accumulate Deaths Score CountdownTimer Switch ElapsedTime Opponents SetDeaths SetResources SetScore SetCountdownTimer SetSwitch );
} @{$EXPORT_TAGS{'all'}};

our @EXPORT_OK = @{$EXPORT_TAGS{'all'}};
our @EXPORT = ();

#------------------------------------
# New If/Then API:
#------------------------------------

our @triggers = ();
our @path = ();

sub Then(&@) {
	return shift;
}

sub If(&@) {
	my ($if, $then) = @_;
	
	addStatement({
		"if" => [],
		"then" => []
	});
	
	push @path, "if";
	$if->();
	
	$path[$#path] = "then";
	$then->();
	
	pop @path;
	return;
}

sub Trigger { 
	push @triggers, [
		[@_]
	];
	@path = ($#triggers);
}

sub addStatement {
	my ($statement) = @_;
	my $ref = \@triggers;
	
	foreach my $point (@path) {
		if ($point eq "if" || $point eq "then") {
			my @arr = @{$ref};
			my %hash = %{$arr[$#arr]};
			$ref = $hash{$point};
		} else {
			my @arr = @{$ref};
			$ref = $arr[$point];
		}
	}
	
	push @{$ref}, $statement;
}

#------------------------------------
# Statement Data
#------------------------------------

our %statements = (

	#------------------------------------
	# Conditions
	#------------------------------------
	
	"Accumulate" => {
		"args" => ["player", "qmod", "n", "resource"]
	},
	
	"Always" => {
		"args" => []
	},
	
	"Bring" => {
		"args" => ["player", "unit", "location", "qmod", "n"]
	},
	
	"Command" => {
		"args" => ["player", "unit", "qmod", "n"]
	},
	
	"CommandTheLeast" => {
		"args" => ["unit"]
	},
	
	"CommandTheLeastAt" => {
		"args" => ["unit", "location"]
	},
	
	"CommandTheMost" => {
		"args" => ["unit"]
	},
	
	"CommandTheMostAt" => {
		"args" => ["unit", "location"]
	},
	
	"CountdownTimer" => {
		"args" => ["qmod", "n"]
	},
	
	"Deaths" => {
		"args" => ["player", "unit", "qmod", "n"]
	},
	
	"ElapsedTime" => {
		"args" => ["qmod", "n"]
	},
	
	"HighestScore" => {
		"args" => ["points"]
	},
	
	"Kill" => {
		"args" => ["player", "unit", "qmod", "n"]
	},
	
	"LeastKills" => { 
		"args" => ["unit"]
	},
	
	"LeastResources" => {
		"args" => ["resource"]
	},
	
	"LowestScore" => {
		"args" => ["points"]
	},
	
	"MostKills" => {
		"args" => ["unit"]
	},
	
	"MostResources" => {
		"args" => ["resource"]
	},
	
	"Never" => {
		"args" => []
	},
	
	"Opponents" => {
		"args" => ["player", "qmod", "n"]
	},
	
	"Score" => {
		"args" => ["player", "points", "qmod", "n"]
	},
	
	"Switch" => {
		"args" => ["switch", "switch_state"]
	},
	
	#------------------------------------
	# Actions
	#------------------------------------
	
	"CenterView" => {
		"args" => ["location"]
	},
	
	"Comment" => {
		"args" => ["text"]
	},
	
	"CreateUnit" => { 
		"args" => ["player", "specific_unit", "n", "location"]
	},
	
	"CreateUnitWithProperties" => {
		"args" => ["player", "specific_unit", "n", "location", "properties"]
	},
	
	"Defeat" => {
		"args" => []
	},
	
	"DisplayTextMessage" => { 
		"args" => ["display_type", "text"]
	},
	
	"Draw" => {
		"args" => []
	},
	
	"GiveUnitsToPlayer" => {
		"args" => ["player", "player", "unit", "amount", "location"]
	},
	
	"KillUnit" => {
		"args" => ["player", "unit"]
	},
	
	"KillUnitAtLocation" => {
		"args" => ["player", "unit", "amount", "location"]
	},
	
	"LeaderBoardControlAtLocation" => {
		"args" => ["text", "unit", "location"]
	},
	
	"LeaderBoardControl" => {
		"args" => ["text", "unit"]
	},	
	
	"LeaderBoardGreed" => {
		"args" => ["n"]
	},	
	
	"LeaderBoardKills" => {
		"args" => ["text", "unit"]
	},	
	
	"LeaderBoardPoints" => {
		"args" => ["text", "points"]
	},	
	
	"LeaderBoardResources" => {
		"args" => ["text", "resource"]
	},

	"LeaderboardComputerPlayers" => {
		"args" => ["state"]
	},	
	
	"LeaderboardGoalControlAtLocation" => {
		"args" => ["text", "n", "unit", "location"]
	},		
	
	"LeaderboardGoalControl" => {
		"args" => ["text", "n", "unit"]
	},
	
	"LeaderboardGoalKills" => {
		"args" => ["text", "n", "unit"]
	},
	
	"LeaderboardGoalPoints" => {
		"args" => ["text", "n", "points"]
	},
	
	"LeaderboardGoalResources" => {
		"args" => ["text", "n", "resource"]
	},
	
	"MinimapPing" => {
		"args" => ["location"]
	},

	"ModifyUnitEnergy" => {
		"args" => ["player", "unit", "percentage", "amount", "location"]
	},
	
	"ModifyUnitHangerCount" => {
		"args" => ["player", "unit", "n", "amount", "location"]
	},
	
	"ModifyUnitHitPoints" => {
		"args" => ["player", "unit", "percentage", "amount", "location"]
	},
	
	"ModifyUnitResourceAmount" => {
		"args" => ["player", "unit", "n", "location"]
	},
	
	"ModifyUnitShieldPoints" => {
		"args" => ["player", "unit", "percentage", "amount", "location"]
	},
	
	"MoveLocation" => {
		"args" => ["player", "unit", "location", "location"]
	},
	
	"MoveUnit" => {
		"args" => ["player", "unit", "amount", "location", "location"]
	},
	
	"Order" => {
		"args" => ["player", "unit", "location", "location", "order"]
	},
	
	"PauseGame" => {
		"args" => []
	},
	
	"PlayWAV" => {
		"args" => ["wav_text"]
	},
	
	"PreserveTrigger" => {
		"args" => []
	},
	
	"RemoveUnit" => {
		"args" => ["player", "unit"]
	},
	
	"RemoveUnitAtLocation" => {
		"args" => ["player", "unit", "amount", "location"]
	},
	
	"RunAIScript" => {
		"args" => ["ai_script"]
	},
	
	"RunAIScriptAtLocation" => {
		"args" => ["ai_script", "location"]
	},
	
	"SetAllianceStatus" => {
		"args" => ["player", "alliance_status"]
	},
	
	"SetCountdownTimer" => {
		"args" => ["vmod", "n"]
	},
	
	"SetDeaths" => {
		"args" => ["player", "unit", "vmod", "n"]
	},
	
	"SetDoodadState" => {
		"args" => ["player", "unit", "location", "state"]
	},
	
	"SetInvincibility" => {
		"args" => ["player", "unit", "location", "state"]
	},
	
	"SetMissionObjectives" => {
		"args" => ["text"]
	},
	
	"SetNextScenario" => {
		"args" => ["text"]
	},
	
	"SetResources" => {
		"args" => ["player", "vmod", "n", "resource"]
	},	
	
	"SetScore" => {
		"args" => ["player", "vmod", "n", "points"]
	},
	
	"SetSwitch" => {
		"args" => ["switch", "switch_action"]
	},
	
	"TalkingPortrait" => {
		"args" => ["unit", "n"]
	},
	
	"Transmission" => {
		"args" => ["display_type", "text", "unit", "location", "vmod", "n", "wav_text", "n"]
	},
	
	"UnmuteUnitSpeech" => {
		"args" => []
	},
	
	"UnpauseGame" => {
		"args" => []
	},
	
	"UnpauseTimer" => {
		"args" => []
	},
	
	"Victory" => {
		"args" => []
	},
	
	"Wait" => {
		"args" => ["n"]
	}

);

#------------------------------------
# Generator
#------------------------------------

sub gn {
	my ($id, @args) = @_;

	addStatement({
		"id" => $id,
		"args" => [@args]
	});
}


#------------------------------------
# Conditions
#------------------------------------

sub Accumulate        {  gn("Accumulate",           @_); }
sub Always            {  gn("Always",               @_);  }
sub Bring             {  gn("Bring",                @_);  }
sub Command           {  gn("Command",              @_);  }
sub CommandTheLeast   {  gn("CommandTheLeast",      @_);  }
sub CommandTheLeastAt {  gn("CommandTheLeastAt",    @_);  }
sub CommandTheMost    {  gn("CommandTheMost",       @_);  }
sub CommandTheMostAt  {  gn("CommandTheMostAt",     @_);  }
sub CountdownTimer    {  gn("CountdownTimer",       @_);  }
sub Deaths            {  gn("Deaths",               @_);  }
sub ElapsedTime       {  gn("ElapsedTime",          @_);  }
sub HighestScore      {  gn("HighestScore",         @_);  }
sub Kill              {  gn("Kill",                 @_);  }
sub LeastKills        {  gn("LeastKills",           @_);  }
sub LeastResources    {  gn("LeastResources",       @_);  }
sub LowestScore       {  gn("LowestScore",          @_);  }
sub MostKills         {  gn("MostKills",            @_);  }
sub MostResources     {  gn("MostResources",        @_); }
sub Never             {  gn("Never",                @_); }
sub Opponents         {  gn("Opponents",            @_); }
sub Score             {  gn("Score",                @_); }
sub Switch            {  gn("Switch",               @_); }


#------------------------------------
# Actions
#------------------------------------

sub CenterView                       { gn("CenterView", @_); }
sub Comment                          { gn("Comment", @_); }
sub CreateUnit                       { gn("CreateUnit", @_); }
sub CreateUnitWithProperties         { gn("CreateUnitWithProperties", @_); }
sub Defeat                           { gn("Defeat", @_); }
sub DisplayTextMessage               { gn("DisplayTextMessage", @_); }
sub Draw                             { gn("Draw", @_);}
sub GiveUnitsToPlayer                { gn("GiveUnitsToPlayer", @_);}
sub KillUnit                         { gn("KillUnit", @_);}
sub KillUnitAtLocation               { gn("KillUnitAtLocation", @_);}
sub LeaderBoardControlAtLocation     { gn("LeaderBoardControlAtLocation", @_);}
sub LeaderBoardControl               { gn("LeaderBoardControl", @_);}
sub LeaderboardGreed                 { gn("LeaderboardGreed", @_);}
sub LeaderBoardKills                 { gn("LeaderBoardKills", @_);}
sub LeaderBoardPoints                { gn("LeaderBoardPoints", @_);}
sub LeaderBoardResources             { gn("LeaderBoardResources", @_);}
sub LeaderboardComputerPlayers       { gn("LeaderboardComputerPlayers", @_);}
sub LeaderboardGoalControlAtLocation { gn("LeaderboardGoalControlAtLocation", @_); }
sub LeaderboardGoalControl           { gn("LeaderboardGoalControl", @_);}
sub LeaderboardGoalKills             { gn("LeaderboardGoalKills", @_);}
sub LeaderboardGoalPoints            { gn("LeaderboardGoalPoints", @_);}
sub LeaderboardGoalResources         { gn("LeaderboardGoalResources", @_);}
sub MinimapPing                      { gn("MinimapPing", @_);}
sub ModifyUnitEnergy                 { gn("ModifyUnitEnergy", @_);}
sub ModifyUnitHangerCount            { gn("ModifyUnitHangerCount", @_);}
sub ModifyUnitHitPoints              { gn("ModifyUnitHitPoints", @_);}
sub ModifyUnitResourceAmount         { gn("ModifyUnitResourceAmount", @_);}
sub ModifyUnitShieldPoints           { gn("ModifyUnitShieldPoints", @_);}
sub MoveLocation                     { gn("MoveLocation", @_) }
sub MoveUnit                         { gn("MoveUnit", @_);}
sub MuteUnitSpeech                   { gn("MuteUnitSpeech", @_);}
sub Order                            { gn("Order", @_);}
sub PauseGame                        { gn("PauseGame", @_);}
sub PauseTimer                       { gn("PauseTimer", @_);}
sub PlayWAV                          { gn("PlayWAV", @_);}
sub PreserveTrigger                  { gn("PreserveTrigger", @_); }
sub RemoveUnit                       { gn("RemoveUnit", @_);}
sub RemoveUnitAtLocation             { gn("RemoveUnitAtLocation", @_);}
sub RunAIScript                      { gn("RunAIScript", @_);}
sub RunAIScriptAtLocation            { gn("RunAIScriptAtLocation", @_);}
sub SetAllianceStatus                { gn("SetAllianceStatus", @_);}
sub SetCountdownTimer                { gn("SetCountdownTimer", @_);}
sub SetDeaths                        { gn("SetDeaths", @_);}
sub SetDoodadState                   { gn("SetDoodadState", @_);}
sub SetInvincibility                 { gn("SetInvincibility", @_);}
sub SetMissionObjectives             { gn("SetMissionObjectives", @_);}
sub SetNextScenario                  { gn("SetNextScenario", @_);}
sub SetResources                     { gn("SetResources", @_);}
sub SetScore                         { gn("SetScore", @_);}
sub SetSwitch                        { gn("SetSwitch", @_);}
sub TalkingPortrait                  { gn("TalkingPortrait", @_);}
sub Transmission                     { gn("Transmission", @_);}
sub UnmuteUnitSpeech                 { gn("UnmuteUnitSpeech", @_);}
sub UnpauseGame                      { gn("UnpauseGame", @_);}
sub UnpauseTimer                     { gn("UnpauseTimer", @_);}
sub Victory                          { gn("Victory", @_);}
sub Wait                             { gn("Wait", @_);}


1;