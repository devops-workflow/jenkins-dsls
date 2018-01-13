/*
// Pipelines, groupings
nestedView('Dashboards') {
  description('')
  views {
*/
dashboardView('Test-dashboard') {
  description('Example Dashboard')
  jobs {
    name('TEST-circleci-artifacts')
  }
  columns {
    status ()
    weather ()
    name ()
    lastSuccess ()
    lastFailure ()
    lastDuration ()
    lastBuildConsole()
    buildButton ()
    customIcon ()
  }
  configure { view ->
    view / 'columns' / 'hudson.plugins.favorite.column.FavoriteColumn' {}
    view / 'columns' / 'hudson.plugins.projectstats.column.NumBuildsColumn' {}
  }
  topPortlets {
    jenkinsJobsList {
      displayName('Job List')
    }
  }
  leftPortlets {
    testStatisticsChart{
      displayName('Test Statistics Chart')
    }
    testStatisticsGrid {
      displayName('Test Statistics Grid')
    }
    testTrendChart {
      displayName('Test Trend Chart')
      displayStatus(DisplayStatus.ALL)
      graphHeight(220)
      graphWidth(300)
    }
  }
  configure { view ->
    view / 'rightPortlets' / 'hudson.plugins.cobertura.dashboard.CoverageTablePortlet' {
      name 'Code Coverages(Cobertura)'
    }
    view / 'rightPortlets' / 'hudson.plugins.projectstats.portlet.NumBuildsPortlet' {
      name 'Project: Number of builds'
    }
  }
  rightPortlets {
    buildStatistics {
      displayName('Build Statistics')
    }
  }
  // bottomPortlets {}
}
