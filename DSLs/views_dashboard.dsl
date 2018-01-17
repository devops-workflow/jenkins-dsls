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
    view / 'rightPortlets' / 'hudson.plugins.checkstyle.dashboard.WarningsTablePortlet' {
      name 'Checkstyle warnings per project'
      canHideZeroWarningsProjects false
    }
    view / 'rightPortlets' / 'hudson.plugins.checkstyle.dashboard.WarningsNewVersusFixedGraphPortlet' {
      name 'Checkstyle warnings trend graph (new vs. fixed)'
      width 500
      height 200
      dayCountString 30
    }
    view / 'rightPortlets' / 'hudson.plugins.checkstyle.dashboard.WarningsUserGraphPortlet' {
      name 'Checkstyle warnings (priority per author)'
      width 500
      height 200
      dayCountString 30
    }
    view / 'rightPortlets' / 'hudson.plugins.checkstyle.dashboard.WarningsPriorityGraphPortlet' {
      name 'Checkstyle warnings trend graph (priority distribution)'
      width 500
      height 200
      dayCountString 30
    }
    view / 'rightPortlets' / 'hudson.plugins.checkstyle.dashboard.WarningsTotalsGraphPortlet' {
      name 'Checkstyle warnings trend graph (totals)'
      width 500
      height 200
      dayCountString 30
    }
  }
  rightPortlets {
    buildStatistics {
      displayName('Build Statistics')
    }
  }
  // bottomPortlets {}
}
