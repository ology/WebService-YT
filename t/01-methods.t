#!perl
use Test::More;

use Mojo::Base -strict;
use Mojolicious;
use Try::Tiny qw(try catch);

use_ok 'WebService::YTSearch';

my $ws = try { WebService::YTSearch->new } catch { $_ };
like $ws, qr/Missing required arguments: key/, 'key required';

$ws = WebService::YTSearch->new( key => '1234567890' );
isa_ok $ws, 'WebService::YTSearch';

my $mock = Mojolicious->new;
$mock->log->level('fatal'); # only log fatal errors to keep the server quiet
$mock->routes->get('/search' => sub {
    my $c = shift;
    my $p = $c->param('q');
    return $c->render(status => 200, json => { ok => 1 }) if $p eq 'foo';
    return $c->render(status => 400, text => 'Missing values');
});
$ws->ua->server->app($mock); # point our UserAgent to our new mock server

$ws->base(Mojo::URL->new(''));

my $data = try {
    $ws->search(query => { q => 'foo' })
} catch { $_ };
is_deeply $data, { ok => 1 }, 'search';

done_testing();
