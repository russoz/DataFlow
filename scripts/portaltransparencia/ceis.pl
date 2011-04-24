#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use DataFlow;
use aliased 'DataFlow::Proc::NOP';
use aliased 'DataFlow::Proc::HTMLFilter';
use aliased 'DataFlow::Proc::URLRetriever';
use aliased 'DataFlow::Proc::MultiPageURLGenerator';
use aliased 'DataFlow::Proc::CSV';
use aliased 'DataFlow::Proc::SimpleFileOutput';

use Data::Dumper;

my $flow = DataFlow->new(
    procs => [
        MultiPageURLGenerator->new(
            name => 'multipage',

            first_page => -2,

            #last_page     => 35,
            produce_last_page => sub {
                my $url = shift;

                use DataFlow::Util::HTTPGet;
                use HTML::TreeBuilder::XPath;

                my $get  = DataFlow::Util::HTTPGet->new;
                my $html = $get->get($url);

                my $texto =
                  HTML::TreeBuilder::XPath->new_from_content($html)
                  ->findvalue('//p[@class="paginaAtual"]');
                die q{Não conseguiu determinar a última página}
                  unless $texto;
                return $1 if $texto =~ /\d\/(\d+)/;
            },
            make_page_url => sub {
                my ( $self, $url, $page ) = @_;

                use URI;

                my $u = URI->new($url);
                $u->query_form( $u->query_form, Pagina => $page );
                return $u->as_string;
            },
        ),
        NOP->new( deref => 1, name => 'nop', ),
        URLRetriever->new( process_into => 1, ),
        HTMLFilter->new(
            process_into => 1,
            search_xpath =>
              '//div[@id="listagemEmpresasSancionadas"]/table/tbody/tr',
        ),
        HTMLFilter->new(
            search_xpath => '//td',
            result_type  => 'VALUE',
            ref_result   => 1,
        ),
        sub {    # remove leading and trailing spaces
            local $_ = shift;
            s/^\s*//;
            s/\s*$//;
            return $_;
        },
        NOP->new( name => 'nop dumper', dump_output => 1, ),
        CSV->new(
            name          => 'csv',
            direction     => 'TO_CSV',
            text_csv_opts => { binary => 1 },
            headers       => [
                'CNPJ/CPF',   'Nome/Razão Social/Nome Fantasia',
                'Tipo',       'Data Inicial',
                'Data Final', 'Nome do Órgão/Entidade',
                'UF',         'Fonte',
                'Data'
            ],
        ),
        SimpleFileOutput->new( file => '> /tmp/ceis.csv', ors => "\n" ),
    ],
);

##############################################################################

my $base = join( '/',
    q{http://www.portaltransparencia.gov.br},
    q{ceis}, q{EmpresasSancionadas.asp?paramEmpresa=0} );

$flow->input($base);

my @res = $flow->flush;

#print Dumper(\@res);

