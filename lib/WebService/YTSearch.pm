package WebService::YTSearch;

# ABSTRACT: Search YouTube

our $VERSION = '0.0304';

use strictures 2;
use Carp qw(croak);
use Mojo::UserAgent ();
use Mojo::JSON qw(decode_json);
use Mojo::URL ();
use Moo;
use Try::Tiny;
use namespace::clean;

=head1 SYNOPSIS

  use WebService::YTSearch;

  my $w = WebService::YTSearch->new( key => '1234567890abcdefghij' );

  my $r = $w->search( q => 'foo', maxResults => 10 );
  print Dumper $r;

=head1 DESCRIPTION

C<WebService::YTSearch> searches YouTube with your API key.

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

Default: C<https://www.googleapis.com>

=cut

has base => (
    is      => 'rw',
    default => sub { 'https://www.googleapis.com' },
);

=head2 ua

The user agent.

Default: C<Mojo::UserAgent-E<gt>new>

=cut

has ua => (
    is      => 'rw',
    default => sub { Mojo::UserAgent->new },
);

=head1 METHODS

=head2 new

  $w = WebService::YTSearch->new(key => $key);

Create a new C<WebService::YTSearch> object given your API B<key>.

=head2 search

  $r = $w->search(%arguments);

Fetch the results given the B<arguments>.

For the accepted arguments, please see the YouTube reference link
below (the main one being C<q>).

=cut

sub search {
    my ( $self, %args ) = @_;

    my $url = Mojo::URL->new( $self->base )
        ->path('youtube/v3/search')
        ->query(
            %args,
            part => 'snippet',
            key  => $self->key,
        );

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

L<Mojo::JSON>

L<Mojo::URL>

L<Mojo::UserAgent>

L<Moo>

L<Try::Tiny>

=cut
