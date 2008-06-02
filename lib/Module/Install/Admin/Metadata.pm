package Module::Install::Admin::Metadata;

use strict;
use YAML::Tiny ();
use Module::Install::Base;

use vars qw{$VERSION @ISA};
BEGIN {
	$VERSION = '0.75';
	@ISA     = 'Module::Install::Base';
}

sub remove_meta {
	my $self = shift;
	my $pkg  = ref($self->_top);
	my $ver  = $self->_top->VERSION;

	return unless -f 'META.yml';
	open META, 'META.yml'
		or die "Can't open META.yml for output:\n$!";
	my $meta = do {local $/; <META>};
	close META;
	return unless $meta =~ /^generated_by: $pkg version $ver/m;
	unless (-w 'META.yml') {
		warn "Can't remove META.yml file. Not writable.\n";
		return;
	}
	warn "Removing auto-generated META.yml\n";
	unless ( unlink 'META.yml' ) {
		die "Couldn't unlink META.yml:\n$!";
	}
	return;
}

sub write_meta {
	my $self = shift;
	if ( -f "META.yml" ) {
		Module::Install::_read("META.yml") =~ /generated_by\:\s*(?:\'|\")\s*Module::Install/s or return;
	} else {
		$self->clean_files('META.yml');
	}
	print "Writing META.yml\n";
	Module::Install::_write("META.yml", $self->dump_meta);
	return;
}

sub dump_meta {
	my $self = shift;
	my $pkg  = ref( $self->_top );
	my $ver  = $self->_top->VERSION;
	my $val  = $self->Meta->{values};

	delete $val->{sign};

	my $perl_version = delete $val->{perl_version};
	if ( $perl_version ) {
		$val->{requires} ||= [];
		my $requires = $val->{requires};

		# Issue warnings for unversioned core modules that are
		# already satisfied by the Perl version dependency.
		require Module::CoreList;
		my $corelist = $Module::CoreList::version{$perl_version};
		if ( $corelist ) {
			my @bad = grep { exists $corelist->{$_} }
			          map  { $_->[0]   }
			          grep { ! $_->[1] }
			          @$requires;
			foreach ( @bad ) {
				# print "WARNING: Unversioned dependency on '$_' is pointless when Perl minimum version is $perl_version\n";
			}
		}

		# Canonicalize to three-dot version after Perl 5.6
		if ( $perl_version >= 5.006 ) {
			$perl_version =~ s{^(\d+)\.(\d\d\d)(\d*)}{join('.', $1, int($2||0), int($3||0))}e
		}
		unshift @$requires, [ perl => $perl_version ];
	}

	# Set a default 'unknown' license
	unless ( $val->{license} ) {
		warn "No license specified, setting license = 'unknown'\n";
		$val->{license} = 'unknown';
	}

	# Most distributions are modules
	$val->{distribution_type} ||= 'module';

	# Check and derive names
	if ( $val->{name} =~ /::/ ) {
		my $name = $val->{name};
		$name =~ s/::/-/g;
		die "Error in name(): '$val->{name}' should be '$name'!\n";
	}
	if ( $val->{module_name} and ! $val->{name} ) {
		$val->{name} = $val->{module_name};
		$val->{name} =~ s/::/-/g;
	}

	# Apply default no_index entries
	$val->{no_index}              ||= {};
	$val->{no_index}->{directory} ||= [];
	foreach my $dir ( qw{ share inc t examples examples demo } ) {
		next unless -d $dir;
		push @{ $val->{no_index}->{directory} }, $dir;
	}

	# Generate the structure we'll be dumping
	my $meta = {};
	foreach my $key ( $self->Meta_ScalarKeys ) {
		next if $key eq 'installdirs';
		next if $key eq 'tests';
		$meta->{$key} = $val->{$key} if exists $val->{$key};
	}
	foreach my $key ( $self->Meta_TupleKeys ) {
		next unless exists $val->{$key};
		$meta->{$key} = { map { @$_ } @{ $val->{$key} } };
	}
	$meta->{provides}     = $val->{provides} if $val->{provides};
	$meta->{author}     &&= [ $meta->{author} ];
	$meta->{no_index}     = $val->{no_index};
	$meta->{generated_by} = "$pkg version $ver";
	$meta->{'meta-spec'}  = {
		version => 1.3,
		url     => 'http://module-build.sourceforge.net/META-spec-v1.3.html',
	};

	YAML::Tiny::Dump($meta);
}

1;
