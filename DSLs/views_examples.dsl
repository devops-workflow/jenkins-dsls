// View tree to show examples of all job and view types

// View types:
//   buildMonitor, buildPipeline, categorizedJobs, dashboard, deliveryPipeline, list, nested, sectioned

nestedView('Examples') {
  description('Examples of view and job types')
  views {
    buildMonitorView('Build Monitor') {
      description('Build Monitor View Example')
      jobs {
        name('Jobs')
        regex(/Example-.*/)
      }
    }
    buildPipelineView('Build Pipeline') {
      filterBuildQueue()
      filterExecutors()
      title('Build Pipeline View Example')
      displayedBuilds(5)
      selectedJob('project-A-compile')
      alwaysAllowManualTrigger()
      showPipelineParameters()
      refreshFrequency(60)
    }
    categorizedJobsView('Categorized') {
      description('Categorized View Example')
      jobFilters {
        regex {
          matchType(MatchType.INCLUDE_MATCHED)
          matchValue(RegexMatchValue.NAME)
          regex('Example-.*')
        }
      }
      //categorizationCriteria {
      //  regexGroupingRule('Puppet_(Module|Template)_(.*)','Puppet $1')
      //}
      columns {
        status ()
        weather ()
        categorizedJob ()
        lastSuccess ()
        lastFailure ()
        lastDuration ()
        buildButton ()
      }
    }
    dashboardView('Dashboard') {
      description('Dashboard View Example')
      jobFilters {
        regex {
          matchType(MatchType.INCLUDE_MATCHED)
          matchValue(RegexMatchValue.NAME)
          regex('Example-.*')
        }
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
      // Portlets available:
      // buildStatistics, jenkinsJobList, testStatisticsChart, testStatisticsGrid, testTrendChart
      topPortlets {
        testStatisticsChart {
          displayName('Test Statistics Chart')
        }
      }
      bottomPortlets {
        testStatisticsGrid {
          displayName('Test Statistics Grid')
          skippedColor('7F7F7F')
          failureColor('FF0000')
        }
      }
    }
    deliveryPipelineView('Delivery Pipeline') {
      pipelineInstances(5)
      showAggregatedPipeline()
      columns(2)
      sorting(Sorting.TITLE)
      updateInterval(60)
      enableManualTriggers()
      showAvatars()
      showChangeLog()
      pipelines {
        component('Sub System A', 'compile-a')
        component('Sub System B', 'compile-b')
        regex(/Example-(.*)/)
      }
    }
    listView('List') {
      description('List View Example')
      jobs {
        regex('Example-.*')
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
    //sectionedView('Sectioned') {}
  }
  columns {
    status ()
    weather ()
  }
}
