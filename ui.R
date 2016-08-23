
ui <- dashboardPage(
  dashboardHeader(title = "RPPS"),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      sidebarMenuOutput("menu")
    )
  ),
  dashboardBody(
    # mainPanel(
    #   
    #   # Plot the performance summary
    #   # Tied to output$perfPlot in server.R
    #   plotOutput("perfPlot"),
    #   
    #   # Table of summary statistics
    #   # Tied to output$summary in server.R
    #   tableOutput("summary")
    #   
    # )
    tabItems(
      tabItem(tabName = "tbiEnte"),
      tabItem(tabName = "tbiDesempenho",
              # fluidRow(
              #   valueBoxOutput("rate"),
              #   valueBoxOutput("count"),
              #   valueBoxOutput("users")
              # ),
              fluidRow(
                box(
                  width = 12,
                  status = "info", solidHeader = TRUE,
                  title = "Desempenho da Carteira",
                  plotOutput("perfPlot", height = "500px")
                )
              )
      ),
      tabItem(tabName = "tbiAlocacao"),
      tabItem(tabName = "tbiSobre",
              fluidRow(
                box(
                  width = 12,
                  status = "info", solidHeader = TRUE,
                  title = "Desempenho da Carteira",
                  includeMarkdown("about.md")
                )
              )
      )
    )
  )
  
  # tabItems(
  #   tabItem("tbiDesempenho"#,
  #           # fluidRow(
  #           #   valueBoxOutput("rate"),
  #           #   valueBoxOutput("count"),
  #           #   valueBoxOutput("users")
  #           # ),
  #           # fluidRow(
  #           #   box(
  #           #     status = "info", solidHeader = TRUE,
  #           #     title = "Desempenho da Carteira",
  #           #     plotOutput("perfPlot")
  #           #   )
  #           # )
  #   ),
  #   tabItem("tbiAlocacao"),
  #   tabItem("tbiSobre",
  #           mainPanel(
  #             includeHTML("about.html")
  #           )
  #   )
  # )
)
