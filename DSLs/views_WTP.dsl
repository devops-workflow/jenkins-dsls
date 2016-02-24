def pipelineView (viewInst, project, desc, job) {
  viewInst.with {
    views {
      buildPipelineView(desc) {
        description("${project} ${desc} workflow")
        title("${project} ${desc}")
        displayedBuilds(5)
        refreshFrequency(60)
        selectedJob("${project}-${job}")
        showPipelineDefinitionHeader()
      }
    }
  }
}

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
    def workflowView = nestedView('Workflows') {
      description('WTP Workflows/Pipelines')
      views {}
      columns {
        status ()
        weather ()
      }
    }
    pipelineView(workflowView, 'VERIFY', 'API Service', 'fe-api-service-analysis')
    pipelineView(workflowView, 'VERIFY', 'Messaging', 'fe-messaging-analysis')
    pipelineView(workflowView, 'VERIFY', 'Portal App', 'fe-portal-app_analysis_NodeJS')
    pipelineView(workflowView, 'VERIFY', 'Portal Services', 'fe-portal-services-analysis')
    pipelineView(workflowView, 'VERIFY', 'Spark Analytics', 'fe-spark-analytics-analysis')
    pipelineView(workflowView, 'VERIFY', 'HAProxy', 'haproxy_analysis_C')
    pipelineView(workflowView, 'VERIFY', 'WX', 'wx_analysis_C')
  }
  columns {
    status ()
    weather ()
  }
}
