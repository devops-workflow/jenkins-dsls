// Defines views for project EX1
//
// This is an sample view setup

def pipelineView (viewInst, project, desc, job) {
  viewInst.with {
    views {
      buildPipelineView(desc) {
        description("${project} ${desc} workflow")
        title("${project} ${desc}")
        displayedBuilds(10)
        refreshFrequency(60)
        selectedJob("${project}-${job}")
        showPipelineDefinitionHeader()
      }
    }
  }
}

nestedView('EX1-DSL') {
  description('Everything related to EX1')
  views {
    listView('EX1') {
      description('EX1 Jobs')
      jobs {
        regex('EX1-.*')
      }
      columns {
        status ()
        weather ()
        name ()
        customIcon ()
        lastSuccess ()
        lastFailure ()
        lastDuration ()
        buildButton ()
      }
    }
    nestedView('Metrics') {
      description('EX1 Metrics')
      views {
      }
    }
    def workflowView = nestedView('Workflows') {
      description('EX1 Workflows/Pipelines')
      views {}
      columns {
        status ()
        weather ()
      }
    }
    pipelineView(workflowView, 'EX1', 'Application 1', 'application-1-job')
    pipelineView(workflowView, 'EX1', 'Application 2', 'application-2-job')
    pipelineView(workflowView, 'EX1', 'Application 3', 'application-3-job')
  }
  columns {
    status ()
    weather ()
  }
}
