// Views to help manage jobs

nestedView('Job Management') {
  description('Views to help manage jobs')
  views {
    dashboardView('Unhappy') {
      description('Unsuccessful jobs')
      jobFilters {
        status {
          matchType(MatchType.INCLUDE_UNMATCHED)
          status(Status.DISABLED)
        }
        status {
          matchType(MatchType.EXCLUDE_MATCHED)
          status(Status.STABLE)
        }
        status {
          matchType(MatchType.EXCLUDE_MATCHED)
          status(Status.ABORTED)
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
        jenkinsJobsList {
          displayName('Unsuccessful jobs')
        }
      }
      leftPortlets {
        testStatisticsChart {
          displayName('Test Statistics Chart')
        }
      }
      rightPortlets {
        buildStatistics {
          displayName('Build Statistics')
        }
        testStatisticsGrid {
          displayName('Test Statistics Grid')
          skippedColor('7F7F7F')
          failureColor('FF0000')
        }
      }
      bottomPortlets {
        testTrendChart {
          displayName('Test Trend Chart')
          displayStatus(DisplayStatus.FAILED)
        }
      }
    }
    //listView('Never Built') {}
    //listView('Not Run Recently') {}
    //listView('Duration High') {}
    //listView('No Success Recently') {}
    listView('Unclassified') {
      description('All jobs that are not in other views')
      jobFilters {
        unclassified {
          matchType(MatchType.INCLUDE_MATCHED)
        }
      }
      columns {
        status ()
        weather ()
        name ()
        customIcon ()
        lastSuccess ()
        lastFailure ()
        lastDuration ()
        disableProject ()
      }
    }
    listView('Disabled') {
      description('All disabled jobs')
      jobFilters {
        status {
          matchType(MatchType.INCLUDE_MATCHED)
          status(Status.DISABLED)
        }
      }
      columns {
        status ()
        weather ()
        name ()
        customIcon ()
        lastSuccess ()
        lastFailure ()
        lastDuration ()
        disableProject ()
      }
    }
    listView('Enabled') {
      description('All enabled jobs')
      jobFilters {
        status {
          matchType(MatchType.INCLUDE_UNMATCHED)
          status(Status.DISABLED)
        }
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
        disableProject ()
      }
    }
    // DSL doesn't have jobFilters for SCM
    nestedView('SCM') {
      description('SCM specific jobs - DSL cannot handle this yet')
      views {
        listView('Git') {
          description('All jobs using git')
          columns {
            status ()
            weather ()
            name ()
            customIcon ()
            lastSuccess ()
            lastFailure ()
            lastDuration ()
            disableProject ()
          }
        }
        listView('None') {
          description('All jobs without a SCM')
          columns {
            status ()
            weather ()
            name ()
            customIcon ()
            lastSuccess ()
            lastFailure ()
            lastDuration ()
            disableProject ()
          }
        }
        listView('Perforce') {
          description('All jobs using Perforce')
          columns {
            status ()
            weather ()
            name ()
            customIcon ()
            lastSuccess ()
            lastFailure ()
            lastDuration ()
            disableProject ()
          }
        }
      }
    }
  }
  columns {
    status ()
    weather ()
  }
}
