use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    dist_name         => 'App-Feeder',
    license           => 'perl',
    dist_author       => q{Mario Domgoergen <mdom@cpan.org>},
    dist_version      => '0.01',
    dist_version_from => 'bin/feeder',
    dist_abstract     => 'Aggreagate and send rss feeds via mail',
    build_requires    => { 'Test::More' => 0, },
    requires          => {
        'LWP::RobotUA'             => 0,
        'XML::FeedPP'              => 0,
        'MIME::Lite'               => 0,
        'Digest::SHA1'             => 0,
        'File::Slurp'              => 0,
        'Config::Tiny'             => 0,
        'Encode'                   => 0,
        'Proc::PID::File'          => 0,
        'HTML::Selector::XPath'    => 0,
        'HTML::TreeBuilder::XPath' => 0,
        'File::Spec::Functions'    => 0,
        'File::Path'               => 0,
        'File::Find::Rule'         => 0,
        'Getopt::Long'             => 0,
        'HTML::Entities'           => 0,
        'parent'                   => 0,
        'Exporter'                 => 0,
        'HTML::ResolveLink'        => 0,
    },
    add_to_cleanup     => ['App-Feeder-*'],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
