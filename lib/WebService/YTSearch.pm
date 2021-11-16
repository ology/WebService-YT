package WebService::YTSearch;

# ABSTRACT: Search YouTube

our $VERSION = '0.0101';

use Moo;
use strictures 2;
use namespace::clean;

use Carp;
use Mojo::UserAgent;
use Mojo::JSON qw( decode_json );
use Mojo::URL;
use Try::Tiny;

=head1 SYNOPSIS

  use WebService::YTSearch;

  my $w = WebService::YTSearch->new( key => '1234567890abcdefghij' );

  my $r = $w->search( query => { q => 'foo', maxResults => 10 } );
  print Dumper $r;

=head1 DESCRIPTION

C<WebService::YTSearch> searches YouTube with your API key. YMMV.

=head1 ATTRIBUTES

=head2 key

Your authorized access key.

=cut

has key => (
    is       => 'ro',
    required => 1,
);

=head2 base

The base URL.

Default: https://www.googleapis.com/youtube/v3/

=cut

has base => (
    is      => 'rw',
    default => sub { 'https://www.googleapis.com/youtube/v3' },
);

=head2 ua

The user agent.

=cut

has ua => (
    is      => 'rw',
    default => sub { Mojo::UserAgent->new },
);

=head1 METHODS

=head2 new

  $w = WebService::YTSearch->new(%arguments);

Create a new C<WebService::YTSearch> object.

=head2 search

  $r = $w->search(%arguments);

Fetch the results given the B<query> arguments.

=cut

sub search {
    my ( $self, %args ) = @_;

    $args{query} = {
        %{ $args{query} },
        part => 'snippet',
        key  => $self->key,
    };

    my $url = Mojo::URL->new($self->base . '/search');

    if ( $args{query} ) {
        $url->query(%{ $args{query} });
    }

    my $tx = $self->ua->get($url);

    my $data = _handle_response($tx);

    return $data;
}

sub _handle_response {
    my ($tx) = @_;

    my $data;

    my $res = $tx->result;

    if ( $res->is_success ) {
        my $body = $res->body;
        try {
            $data = decode_json($body);
        }
        catch {
            croak $body, "\n";
        };
    }
    else {
        croak "Connection error: ", $res->message, "\n";
    }

    return $data;
}

1;
__END__

=head1 SEE ALSO

The examples in the F<eg/> directory.

The tests in F<t/01-methods.t>

L<https://developers.google.com/youtube/v3/docs/search/list>

L<Moo>

L<Mojo::JSON>

L<Mojo::UserAgent>

L<Mojo::URL>

L<Try::Tiny>

=cut
