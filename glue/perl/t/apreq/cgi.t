use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil qw(t_cmp t_debug t_write_perl_script);
use Apache::TestConfig;
use Apache::TestRequest qw(GET_BODY UPLOAD_BODY POST_BODY GET_RC GET_HEAD);
use constant WIN32 => Apache::TestConfig::WIN32;
use HTTP::Cookies;

my @key_len = (5, 100, 305);
my @key_num = (5, 15, 26);
my @keys    = ('a'..'z');

my $cgi = File::Spec->catfile(Apache::Test::vars('serverroot'),
                              qw(cgi-bin test_cgi.pl));

t_write_perl_script($cgi, <DATA>);

#########################################################
# uncomment the following to test larger keys
my @big_key_len = (100, 500, 5000, 10000);
# if the above is uncommented, comment out the following
#my @big_key_len = (100, 500, 1000, 2500);
#########################################################
my @big_key_num = (5, 15, 25);
my @big_keys    = ('a'..'z');

plan tests => 10 + @key_len * @key_num + @big_key_len * @big_key_num;

my $location = '/cgi-bin';
my $script = $location . '/test_cgi.pl';
my $line_end = WIN32 ? "\r\n" : "\n";
my $filler = "0123456789" x 6400; # < 64K

# GET
for my $key_len (@key_len) {
    for my $key_num (@key_num) {
        my @query = ();
        my $len = 0;

        for my $key (@keys[0..($key_num-1)]) {
            my $pair = "$key=" . 'd' x $key_len;
            $len += length($pair) - 1;
            push @query, $pair;
        }
        my $query = join ";", @query;

        t_debug "# of keys : $key_num, key_len $key_len";
        my $body = GET_BODY "$script?$query";
        ok t_cmp($len,
                 $body,
                 "GET long query");
    }

}

# POST
for my $big_key_len (@big_key_len) {
    for my $big_key_num (@big_key_num) {
        my @query = ();
        my $len = 0;

        for my $big_key (@big_keys[0..($big_key_num-1)]) {
            my $pair = "$big_key=" . 'd' x $big_key_len;
            $len += length($pair) - 1;
            push @query, $pair;
        }
        my $query = join ";", @query;

        t_debug "# of keys : $big_key_num, big_key_len $big_key_len";
        my $body = POST_BODY($script, content => $query);
        ok t_cmp($len,
                 $body,
                 "POST big data");
    }

}

ok t_cmp("\tfoo => 1$line_end", 
         POST_BODY("$script?foo=1", Content => $filler), "simple post");

ok t_cmp("\tfoo => ?$line_end\tbar => hello world$line_end", 
         GET_BODY("$script?foo=%3F&bar=hello+world"), "simple get");

my $body = POST_BODY($script, content => 
                     "aaa=$filler;foo=1;bar=2;filler=$filler");
ok t_cmp("\tfoo => 1$line_end\tbar => 2$line_end", 
         $body, "simple post");

$body = POST_BODY("$script?foo=1", content => 
                  "intro=$filler&bar=2&conclusion=$filler");
ok t_cmp("\tfoo => 1$line_end\tbar => 2$line_end", 
         $body, "simple post");

$body = UPLOAD_BODY("$script?foo=1", content => $filler);
ok t_cmp("\tfoo => 1$line_end", 
         $body, "simple upload");


{
    my $test  = 'netscape';
    my $key   = 'apache';
    my $value = 'ok';
    my $cookie = qq{$key=$value};
    ok t_cmp($value,
             GET_BODY("$script?test=$test&key=$key", Cookie => $cookie),
             $test);
}
{
    my $test  = 'rfc';
    my $key   = 'apache';
    my $value = 'ok';
    my $cookie = qq{\$Version="1"; $key="$value"; \$Path="$location"};
    ok t_cmp(qq{"$value"},
             GET_BODY("$script?test=$test&key=$key", Cookie => $cookie),
             $test);
}
{
    my $test  = 'encoded value with space';
    my $key   = 'apache';
    my $value = 'okie dokie';
    my $cookie = "$key=" . join '',
        map {/ / ? '+' : sprintf '%%%.2X', ord} split //, $value;
    ok t_cmp($value,
             GET_BODY("$script?test=$test&key=$key", Cookie => $cookie),
             $test);
}
{
    my $test  = 'bake';
    my $key   = 'apache';
    my $value = 'ok';
    my $cookie = "$key=$value";
    my ($header) = GET_HEAD("$script?test=$test&key=$key", 
                            Cookie => $cookie) =~ /^#Set-Cookie:\s+(.+)/m;
    ok t_cmp($cookie, $header, $test);
}
{
    my $test  = 'bake2';
    my $key   = 'apache';
    my $value = 'ok';
    my $cookie = qq{\$Version="1"; $key="$value"; \$Path="$location"};
    my ($header) = GET_HEAD("$script?test=$test&key=$key", 
                            Cookie => $cookie) =~ /^#Set-Cookie2:\s+(.+)/m;
    ok t_cmp(qq{$key="$value"; Version=1; path="$location"}, $header, $test);
}

__DATA__
use strict;
use File::Basename;
use warnings FATAL => 'all';
use Apache2;
use APR;
use APR::Pool;
use lib qw(../../blib/lib/Apache2
           ../../blib/arch/Apache2);
use Apache::Request;
use Apache::Cookie;

my $p = APR::Pool->new();
print "Content-Type: text/plain\n\n";

apreq_log("Creating Apache::Request object");
my $req = Apache::Request->new($p);

my $foo = $req->param("foo");
my $bar = $req->param("bar");

my $test = $req->param("test");
my $key  = $req->param("key");

if ($foo || $bar) {
    if ($foo) {
        apreq_log("foo => $foo");
        print "\tfoo => $foo\n";
    }
    if ($bar) {
        apreq_log("bar => $bar");
        print "\tbar => $bar\n";
    }
}
    
elsif ($test && $key) {
    my %cookies = Apache::Cookie->fetch($p);
    apreq_log("Fetching cookie $key");
    if ($cookies{$key}) {
        if ($test eq "bake") {
            $cookies{$key}->bake;
        }
        elsif ($test eq "bake2") {
            $cookies{$key}->bake2;
        }
        print $cookies{$key}->value;
    }
}

else {
    my $len = 0;
    apreq_log("Fetching all parameters");
    for ($req->param) {
        my $param = $req->param($_);
        next unless $param;
        apreq_log("$_ => $param");
        $len += length($_) + length($param);
    }
    print $len;
}

sub apreq_log {
    my $msg = shift;
    my ($pkg, $file, $line) = caller;
    $file = basename($file);
    print STDERR "$file($line): $msg\n";    
}
