#!perl
use Test::More;
use Test::Exception;

use Mojo::Base -strict;
use Mojolicious;

use_ok 'WebService::YTSearch';

throws_ok { WebService::YTSearch->new }
    qr/Missing required arguments: key/, 'key required';

my $ws = new_ok 'WebService::YTSearch' => [ key => '1234567890' ];

my $mock = Mojolicious->new;
$mock->log->level('fatal'); # only log fatal errors to keep the server quiet
$mock->routes->get('/search' => sub {
    my $c = shift;
    is $c->param('q'), 'foo', 'q param';
    is $c->param('part'), 'snippet', 'part param';
    is $c->param('key'), '1234567890', 'key param';
    return $c->render(status => 200, json => { ok => 1 });
});
$ws->ua->server->app($mock); # point our UserAgent to our new mock server

$ws->base('');

lives_ok { $ws->search(q => 'foo') } 'search';

done_testing();
