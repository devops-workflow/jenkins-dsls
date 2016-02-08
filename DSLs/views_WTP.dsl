nestedView('WTP-DSL') {
  description('Everything related to WTP')
  views {
    listView('WTP') {
      description('WTP Jobs')
      jobs {
        regex('WTP-.*')
      }
      columns {
        status ()
        weather ()
        name ()
        lastSuccess ()
        lastFailure ()
        lastDuration ()
        buildButton ()
      }
    }
    nestedView('Metrics') {
      description('WTP Metrics')
      views {
      }
    }
    nestedView('Workflows') {
      description('WTP Workflows/Pipelines')
      views {
        buildPipelineView('API Service') {
          description('WTP API Service workflow')
          title('WTP API Service')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-api-service_analysis')
          showPipelineDefinitionHeader()
        }
        buildPipelineView('HAProxy') {
          description('WTP HAProxy workflow')
          title('WTP HAProxy')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-haproxy_analysis')
          showPipelineDefinitionHeader()
        }
        buildPipelineView('Messaging') {
          description('WTP Messaging workflow')
          title('WTP Messaging')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-fe-messaging_analysis')
          showPipelineDefinitionHeader()
        }
        buildPipelineView('Portal App') {
          description('WTP Portal App workflow')
          title('WTP Portal Application')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-fe-portal-app_analysis')
          showPipelineDefinitionHeader()
        }
        buildPipelineView('Portal Services') {
          description('WTP Portal Services workflow')
          title('WTP Portal Services')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-fe-portal-services_analysis')
          showPipelineDefinitionHeader()
        }
        buildPipelineView('Spark') {
          description('WTP Spark Analytics workflow')
          title('WTP Spark Analytics')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-fe-spark-analytics_analysis')
          showPipelineDefinitionHeader()
        }
        buildPipelineView('WX') {
          description('WTP WX workflow')
          title('WTP WX')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-WX_analysis')
          showPipelineDefinitionHeader()
        }
      }
      columns {
        status ()
        weather ()
      }
    }
  }
  columns {
    status ()
    weather ()
  }
}
