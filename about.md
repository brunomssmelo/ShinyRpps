### Welcome to the Brazilian Government Workers Retirement Systems Investment Portfolio Analyzer

This application is a project that has started on 2016-07-01 (a few weeks ago)

It is based on the following datasets:

- Investment portfolios of government workers retirement systems of brazilian states and cities (municipalities),
which is available in [MPS - Ministerio da Previdencia Social](http://cadprev.previdencia.gov.br/Cadprev/faces/pages/modulos/didf/consultarDemonstrativos.xhtml)

- Brazilian investment funds data, which is available in [CVM - Comissao de Valores Mobiliarios](http://www.cvm.gov.br/menu/regulados/fundos/consultas/fundos/fundos.html)

As of today (2016-07-11), only very few features are available. There is data about three cities within the brazilian State of Rio de Janeiro:

- Rio de Janeiro
- Queimados
- Niteroi

It is possible to visualize the retirement system's combined portfolio'a (RPPS) performance and the performance of individual funds within it. The benchmark is the brazilian inflation plus a 6% interest rate (which is the "actuarial" target)

Source code is available on the [GitHub](https://github.com/brunomssmelo/ShinyRpps).

Two packages are being developed to obtain the data from the sources mentioned above:

- [RcvmWrangler](https://github.com/brunomssmelo/RcvmWrangler): accesses a web service [CVM WDSL](http://sistemas.cvm.gov.br/webservices/Sistemas/SCW/CDocs/WsDownloadInfs.asmx) to obtain xml files with data about the brazilian funds.

- [RppsWrangler](https://github.com/brunomssmelo/RppsWrangler): extracts data about the retirement systems investment portfolios from pdf files downloaded from [MPS - Ministerio da Previdencia Social](http://cadprev.previdencia.gov.br/Cadprev/faces/pages/modulos/didf/consultarDemonstrativos.xhtml).
