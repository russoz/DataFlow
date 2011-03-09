#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use aliased 'DataFlow::Node';
use aliased 'DataFlow::Chain';
use aliased 'DataFlow::Node::LiteralData';
use aliased 'DataFlow::Node::NOP';
use aliased 'DataFlow::Node::HTMLFilter';
use aliased 'DataFlow::Node::URLRetriever';
use aliased 'DataFlow::Node::MultiPageURLGenerator';
use aliased 'DataFlow::Node::CSV';
use aliased 'DataFlow::Node::SimpleFileOutput';

my $base = join( '/',
    q{http://www.portaltransparencia.gov.br},
    q{ceis}, q{EmpresasSancionadas.asp?paramEmpresa=0} );

my $chain = Chain->new(
    links => [
        LiteralData->new( data => $base, ),
        MultiPageURLGenerator->new(
            name => 'multipage',

            #first_page => -2,
            #last_page     => 35,
            produce_last_page => sub {
                my $url = shift;

                use DataFlow::Node::URLRetriever::Get;
                use HTML::TreeBuilder::XPath;

                my $get  = DataFlow::Node::URLRetriever::Get->new;
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
        Node->new(
            process_into => 1,
            process_item => sub {
                shift;
                local $_ = shift;
                s/^\s*//;
                s/\s*$//;
                return $_;
            }
        ),
        CSV->new(
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
		#NOP->new( dump_output => 1 ),
    ],
);

$chain->flush;

