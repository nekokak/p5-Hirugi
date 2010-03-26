package Hirugi;
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use Carp qw//;

our $VERSION = '0.01';

sub new {
    my ($class, $args) = @_;

    my $self = bless {
        host  => $args->{host},
        rules => $args->{rules}||{},
        ua    => $args->{ua}||'',
    }, $class;

    $self;
}

sub ua {
    my $self = shift;
    $self->{ua} or do {
        $self->{ua} = LWP::UserAgent->new(
            agent   => "Hirugi/ $VERSION",
            timeout => 5,
        );
    };
}

sub _rule {
    my ($self, $key) = @_;

    my $rule = $self->{rules}->{$key};
    unless ($rule) {
        Carp::croak('[error] unknown rules: '. $key);
    }
    $rule;
}

sub get_path {
    my ($self, $key, $args) = @_;

    sprintf('http://%s%s',
        $self->{host},
        sprintf($self->_rule($key), @$args),
    );
}

sub store_content {
    my ($self, $key, $args, $data) = @_;

    my $req = HTTP::Request->new(
        PUT => sprintf('http://%s%s', $self->{host}, sprintf($self->_rule($key), @$args))
    );
    my $ua  = LWP::UserAgent->new;

    $req->content($data);
    my $res = $self->ua->request($req);
    unless ($res->is_success) {
        Carp::croak("[error] oops! can't PUT contents. key=$key");
    }
}

sub remove {
    my ($self, $key, $args) = @_;

    my $req = HTTP::Request->new(
        DELETE => sprintf('http://%s%s', $self->{host}, sprintf($self->_rule($key), @$args))
    );
    my $ua  = LWP::UserAgent->new;
    my $res = $self->ua->request($req);
    unless ($res->is_success) {
        Carp::croak("[error] oops! can't DELETE contents. key=$key");
    }
}

1;

__END__

=head1 NAME

Hirugi - undistributed filesystem manager on perlbal

=head1 SYNOPSIS

perlbal config:

  CREATE SERVICE hirugi_server
      SET listen         = 192.168.1.13:7000
      SET role           = web_server
      SET docroot        = /path/to/contents_dir/
      SET dirindexing    = 0
      SET persist_client = on
      SET enable_put     = 1
      SET enable_delete  = 1
  ENABLE hirugi_server

your script:

  use Hirugi;
  my $hirugi = Hirugi->new(
      {
          host  => '192.168.1.13:7000',
          rules => +{
              image => '/test/image/%s/%s.%s',
          },
      }
  );
  $hirugi->store_content($key => ['a','b','gif'], $data);
  # get reproxy_path
  $hirugi->get_path($key => ['a','b','gif']);
  $hirugi->remove($key => ['a','b','gif']);

=head1 DESCRIPTION

Hirugi is undistributed filesystem manager on perlbal.

=head1 AUTHOR

Atsushi Kobayashi E<lt>nekokak _at_ gmail _dot_ comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

