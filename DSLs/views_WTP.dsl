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
        buildPipelineView('HAProxy') {
          description('WTP HAProxy workflow')
          title('WTP HAProxy')
          displayedBuilds(5)
          refreshFrequency(60)
          selectedJob('WTP-haproxy_analysis')
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
