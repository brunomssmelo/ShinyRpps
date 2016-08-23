#--- Carregamento de bibliotecas
library(shiny)
library(shinydashboard)

#--- Funcoes auxiliares
geraDados <- function(nmEnte, dtCvm, dtDair, dtIpca, dtLivreRisco) {
  
  if (is.null(dtDair) | (prod(dim(dtDair))==0)) {
    return(NULL)
  }
  
  if (is.null(dtCvm) | (prod(dim(dtCvm))==0)) {
    return(NULL)
  }
  
  dtDair <- dtDair[dtDair$ENTE == nmEnte,]
  dtCvm <- dtCvm[dtCvm$CNPJ_FDO %in% dtDair$CNPJ_FUNDO,]
  
  # Calcula, a partir dos dados contidos nos DAIR e dos informes diarios dos fundos disponibilizados pela CVM,
  # o retorno da carteira de investimentos do RPPS.
  rtRpps <- RppsAnalytics::rppsDesempenho(dtDair = dtDair, dtCvm = dtCvm)
  
  # Reordena as colunas relativas aos fundos de acordo com o atributo "TIPO ATIVO"
  tipoAtivo <- attr(rtRpps, which = "tipo_ativo")
  novaOrdem <- order(tipoAtivo)
  rtRpps <- rtRpps[, c(1, 1 + novaOrdem)]
  attr(x = rtRpps, which = "tipo_ativo") <- tipoAtivo[novaOrdem]
  
  # Acopla um indice de referencia (IPCA) na serie temporal de retornos
  rtRpps <- RppsAnalytics::rppsAcoplaReferencia(retornos = rtRpps,
                                                referencia = dtIpca,
                                                nome.ref = "IPCA",
                                                taxa = 0,
                                                periodo.taxa = "ANO")
  
  # Acopla um indice de referencia (IPCA + %5 a.a) na serie temporal de retornos
  rtRpps <- RppsAnalytics::rppsAcoplaReferencia(retornos = rtRpps,
                                                referencia = dtIpca,
                                                nome.ref = "IPCA + 5% a.a.",
                                                taxa = 5,
                                                periodo.taxa = "ANO")
  
  # Acopla a taxa livre de risco a serie temporal de retornos.
  rtRpps <- RppsAnalytics::rppsAcoplaTaxaLivreRisco(retornos = rtRpps,
                                                    taxa = dtLivreRisco,
                                                    nome.taxa = "LFT 2021")
  
  # Extrai de rtRpps a coluna relativa aos retornos da carteira do RPPS
  colRpps <- attr(rtRpps, which = "col_rpps")
  
  # Extrai de rtRpps a coluna relativa a Taxa Livre de Risco
  colLivreRisco <- attr(rtRpps, which = "col_taxa_livre_risco")
  
  # Extrai de rtRpps as colunas relativas aos indices de referencia
  colIndicesRef <- attr(rtRpps, which = "col_indices_ref")
  
  rtRpps
}

constroiSubMenuTipoAtivo <- function(data, dataVarName = as.character(substitute(data))){
  
  id <- sort(unique(as.integer(attr(data, which = "tipo_ativo"))))
  # nm <- as.character(levels(attr(analysis_data, which = "tipo_ativo")))[id]
  
  code <- 
    'menuItem(
      "Desempenho",
      tabName = "tbiDesempenho",
      menuSubItem(
        checkboxGroupInput(
        "tipo0", "Portfolio RPPS",
        choices  = list("RPPS" = 1),
        selected = 1)
    )'
      
  chunk <- 
    'menuSubItem(
      checkboxGroupInput("tipo_N_", as.character(levels(attr(_VAR_NAME_, which = "tipo_ativo")))[_N_],
      choices  = refresh_checkbox(tipo = levels(attr(_VAR_NAME_, which = "tipo_ativo"))[_N_]))
    )'

  for (i in 1:(length(id))) {
    code <- paste(
      code,
      stringr::str_replace_all(
        string = stringr::str_replace_all(string = chunk,
                               pattern = "_N_",
                               replacement = id[i]),
        pattern = "_VAR_NAME_",
        replacement = dataVarName),
      sep = ",\n")
  }
  
  code <- paste0(code, "\n)")
  code
}

#--- Inicializacao de variaveis

# Carrega serie historica do IPCA
dtIpca <- readRDS("./data/ipca_201605.rds")

# Carrega dados de DAIRs
dtDair <- readRDS("./data/DairData.rds")

# Lista de tipos de ativos segundo Resolucao CMN nº 3.933/2010
tipoAtivo <- levels(dtDair$TIPO_ATIVO)

# Carrega informacoes dos fundos a partir do arquivo anual dos informes diários dos fundos registrados na CVM
# O pacote RcvmWrangler [Rcvmwrangler]{https://github.com/brunomssmelo/RcvmWrangler} permite a obtencao dos mesmos.
dtCvm <- readRDS("./data/CvmData.rds")

# Carrega a serie historica da "LFT 2021" (ela sera utilizada como taxa livre de risco)
# [Series Historicas Titulos do Tesouro]{http://www.tesourotransparente.gov.br/ckan/dataset/taxas-dos-titulos-ofertados-pelo-tesouro-direto}
dtLivreRisco <- readRDS("./data/lft_2021.rds")

# extrai nomes dos entes
data_sets <- unique(dtDair$ENTE)

# inicializa dataset_name
dataset_name <- data_sets[1]

# seleciona o 1º ente da lista
selected_funds <- 1

# inicializa app com dados do RJPrev
analysis_data <- geraDados(
  #"Governo do Estado do Rio de Janeiro",
  "Prefeitura Municipal de Niteroi",
  dtCvm = dtCvm,
  dtDair = dtDair,
  dtIpca = dtIpca,
  dtLivreRisco = dtLivreRisco
)

server <- function(input, output, session) {
  
  # trabalhando aqui
  refresh_checkbox <- function(tipo){
    
    data <- analysis_data
    
    tipoAtivo <- attr(data, which = "tipo_ativo")
    colFundos <- attr(data, which = "col_fundos")
    data <- data[,colFundos]
    data <- data[,tipoAtivo == tipo]
    
    fund_names <- gsub(pattern = "[.]", replacement = " ", x = colnames(data))
    choices <- 1:length(fund_names)
    names(choices) <- iconv(enc2native(fund_names), to = "ASCII//TRANSLIT")
    
    choices
  }
  
  refresh_checkbox_data <- reactive({
    # If missing input, return to avoid error later in function
    if(is.null(input$dataset))
      return(NULL)

    # Get the data set with the appropriate name
    dataset_name <- input$dataset
    #colnames <- c("RPPS (COMBINED PORTFOLIO)", dtDair[ENTE == dataset_name]$FUNDO)
    fund_names <- gsub(pattern = "[.]", replacement = " ", x = colnames(analysis_data))
    choices <- 1:length(fund_names)
    names(choices) <- iconv(enc2native(fund_names), to = "ASCII//TRANSLIT")

    choices
  })
  
  output$menu <- renderMenu({
    # sidebarMenu(
    #   menuItem("Menu item", icon = icon("calendar"))
    # )
    sidebarMenu(
      menuItem("RPPS",
               tabName = "tbiEnte",
               menuSubItem(
                 tabName = "tbiDesempenho",
                 selectInput("dataset",
                             "Regime Próprio",
                             as.list(data_sets), selected = input$dataset)
               )
      ),
      eval(parse(text = constroiSubMenuTipoAtivo(analysis_data))),
      menuItem("Alocacao", tabName = "tbiAlocacao"),
      menuItem("Sobre",tabName = "tbiSobre")
    )
  })
  isolate({updateTabItems(session = session,
                          inputId = "tabs",
                          selected = "tbiDesempenho")})
  
  refresh_data <- reactive({
    # If missing input, return to avoid error later in function
    if(is.null(input$dataset))
      return(analysis_data)
    
    datset_name <- input$dataset
    
    return(
      
      analysis_data <- geraDados(nmEnte = datset_name, 
                                 dtCvm = dtCvm,
                                 dtDair = dtDair,
                                 dtLivreRisco = dtLivreRisco,
                                 dtIpca = dtIpca)
    )
  })
  
  # Use charts.PerformanceSummary from Performance Analytics package
  # to generate a performance summary plot
  output$perfPlot <- renderPlot({
    
    analysis_data <- refresh_data()
    
    # Constroi lista de Ativos Selecionados
    id <- sort(as.integer(attr(analysis_data, which = "tipo_ativo")))
    uniqueId <- unique(id)
    
    ativosSelecionados <- as.numeric(input$tipo0)
    for (i in 1:length(uniqueId)){
      if (i == 1){
        ajuste <- 1
      }else{
        ajuste <- ajuste + sum(id == uniqueId[i-1])
      }
      ativosSelecionados <- c(ativosSelecionados,
                              ajuste + as.integer(eval(parse(text = paste0("input$tipo",uniqueId[i])))))
    }
    
    selected_funds <- ativosSelecionados
    datset_name <- input$dataset
    
    col.benchmark <- ncol(analysis_data)-1
    
    # PerformanceAnalytics::charts.PerformanceSummary(
    #   analysis_data[, c(selected_funds)],
    #   cex.axis = 2)
    
    if ((prod(dim(analysis_data)) > 0) &  (length(selected_funds) > 0)) {
      RppsAnalytics::rppsPlotaDesempenho(analysis_data[, c(selected_funds)])
    }
  })
  
  # Use table.Stats from Performance Analytics package
  # to generate a table of summary statistics
  # output$summary <- renderTable({
  #   
  #   # browser()
  #   selected_funds <- as.numeric(input$funds)
  #   datset_name <- input$dataset
  #   
  #   analysis_data <- refresh_data()
  #   col.benchmark <- ncol(analysis_data)-1
  #   
  #   PerformanceAnalytics::table.Stats(analysis_data[, c(selected_funds, col.benchmark)])
  # })
  
}
