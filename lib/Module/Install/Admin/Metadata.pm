package Module::Install::Admin::Metadata;

use strict;
use Module::Install::Base;

use vars qw{$VERSION @ISA};
BEGIN {
	$VERSION = '0.68';
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

    META_NOT_OURS: {
        local *FH;
        if ( open FH, "META.yml" ) {
            while (<FH>) {
                last META_NOT_OURS if /^generated_by: Module::Install\b/;
            }
            return if -s FH;
        }
    }

    print "Writing META.yml\n";

    local *META;
    open META, "> META.yml" or warn "Cannot write to META.yml: $!";
    print META $self->dump_meta;
    close META;

    return;
}

sub dump_meta {
    my $self = shift;
    my $pkg  = ref( $self->_top );
    my $ver  = $self->_top->VERSION;
    my $val  = $self->Meta->{'values'};

    delete $val->{sign};

    if ( my $perl_version = delete $val->{perl_version} ) {
        # Always canonical to three-dot version
        if ( $perl_version >= 5.006 ) {
        	$perl_version =~ s{^(\d+)\.(\d\d\d)(\d*)}{join('.', $1, int($2||0), int($3||0))}e
        }
        $val->{requires} = [
            [ perl => $perl_version ],
            @{ $val->{requires} || [] },
        ];
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
    $val->{no_index} ||= {};
    $val->{no_index}->{directory} ||= [];
    foreach my $dir ( qw{ share inc t } ) {
        next unless -d $dir;
	push @{ $van->{no_index}->{directory} }, $dir;
    }

    # Generate the structure we'll be dumping
    my $meta = {};
    foreach my $key ($self->Meta_ScalarKeys) {
        $meta->{$key} = $val->{$key} if exists $val->{$key};
    }
    foreach my $key ($self->Meta_TupleKeys) {
        next unless exists $val->{$key};
        $meta->{$key} = { map { @$_ } @{ $val->{$key} } };
    }
    $meta->{provides}     = $val->{provides} if $val->{provides};
    $meta->{author}       &&= [ $meta->{author} ];
    $meta->{no_index}     = $val->{no_index};
    $meta->{generated_by} = "$pkg version $ver";
    $meta->{'meta-spec'}  = {
        version => 1.3,
        url     => 'http://module-build.sourceforge.net/META-spec-v1.3.html',
    };

    # Dump the data structure
    local $@;
    if ( eval { require YAML::Syck } ) {
        # Why no header? It is required by the spec!
        # local $YAML::Syck::Headless = 1;
        return YAML::Syck::Dump($meta);

    } elsif ( eval { require YAML::Tiny } ) {
        return YAML::Tiny::Dump($meta);

    } else {
        require YAML;
        # Why no header? It is required by the spec!
        # local $YAML::UseHeader = 0;
        return YAML::Dump($meta);

    }

    return;
}

1;
