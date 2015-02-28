#!/usr/bin/env perl
use strict;
use warnings;
use v5.10.0;
use Imager::Screenshot 'screenshot';
use Imager;
use Getopt::Long;
use Image::Imgur 'host';
use HTTP::Request;
use LWP 5.64;
use JSON;
use File::Open qw(fopen);
use Data::Munge;
use MIME::Base64;
# Delay option that has the default value of 3 seconds
my $delay = 3;
# Output option that has the default output file of 'output.jpg'
my $output = "output.jpeg";
# Upload option that says whether to upload the screenshot to imgur or not. Default is true
#my $upload = 
GetOptions('delay|d=i' => \$delay,
	   'output|o=s' => \$output);

say "Will take screenshot in $delay seconds...";
sleep($delay);

my $desktop = screenshot();

$desktop->write(file => $output) or die $desktop->errstr;

my $clientid = "8606b5c56225c40";
my $browser = LWP::UserAgent->new;
my $url = "https://api.imgur.com/3/image";
my @headers = ('Authorization' => "Client-ID $clientid");
my @form_data = ['image' => $output];
my $binary = slurp fopen($output, 'rb');
my $binary_encoded = encode_base64($binary, '');
my $response = $browser->post($url, ['image' => $binary_encoded, 'type' => 'base64'], @headers);

my $content = $response->content;
my $data = decode_json($content);
say $data->{"data"}->{"link"};
die "Can't get $url -- ", $response->status_line
   unless $response->is_success;

say "Screenshot saved to $output";
say "Uploaded to: $content";

