package App::Feeder::PageContent;

use strict;
use warnings;
use HTML::TreeBuilder::XPath;
use HTML::Selector::XPath;
use HTML::ResolveLink;
use Params::Validate qw(validate);
use LWP::UserAgent;
use Carp qw(croak);
use Exporter;
use parent qw(Exporter);

our @EXPORT_OK = qw(get_content);

sub get_all_links {
    my ( $response, $selector ) = @_;

    my $tree =
      HTML::TreeBuilder::XPath->new->parse( $response->decoded_content() )->eof;
    my $xpath = HTML::Selector::XPath->new($selector)->to_xpath;
    my @urls;
    for my $elem ( $tree->findnodes($xpath) ) {
        my $rel_url  = $elem->attr_get_i('href');
        my $base_url = $response->base;
        push @urls, URI->new_abs( $rel_url, $base_url );
    }
    return @urls;
}

sub unpaginate {
    my ( $ua, $url, $page_selector, $content_selector ) = @_;

    my @responses;
    push @responses, _get( $ua, $url );
    my @urls = get_all_links( $responses[0], $page_selector );
    for my $url (@urls) {
        push @responses, _get( $ua, $url );
    }
    my $content = '';
    for my $response (@responses) {
        $content .= filter_content( $response, $content_selector );
    }
    return $content;
}

sub filter_content {
    my ( $response, $selector ) = @_;
    my $tree =
      HTML::TreeBuilder::XPath->new->parse( $response->decoded_content )->eof;
    my $xpath = HTML::Selector::XPath->new($selector)->to_xpath;
    my $html = $tree->findnodes_as_string($xpath);

    my $resolver = HTML::ResolveLink->new( base => $response->base );
    return $resolver->resolve($html);
}

sub get_content {
    my %args = validate(
        @_, {
        ua  => { default => LWP::UserAgent->new( env_proxy => 1 ) },
        url => 1,
        selector  => 1,
        multipage => 0,
    });

    my $content;
    if ( $args{multipage} ) {
        $content =
          unpaginate( $args{ua}, $args{url}, $args{multipage},
            $args{selector} );
    }
    else {
        $content = filter_content( _get( $args{ua}, $args{url} ),
            $args{selector} );
    }
    return $content;
}

sub _get {
    my ( $ua, $url ) = @_;
    my $response = $ua->get($url);
    if ( !$response->is_success ) {
        croak $response->status_line;
    }
    return $response;
}

1;
__END__
