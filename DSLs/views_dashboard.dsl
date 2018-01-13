
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
      graphHeight('220')
      graphWidth('300')
    }
  }
  configure { view ->
    view / 'rightPortlets' / 'hudson.plugins.cobertura.dashboard.CoverageTablePortlet' {}
  }
  rightPortlets {
    buildStatistics {
      displayName('Build Statistics - Project: Number of builds')
    }
  }
  /*<rightPortlets>
    <hudson.plugins.cobertura.dashboard.CoverageTablePortlet plugin="cobertura@1.12">
      <id>dashboard_portlet_22289</id>
      <name>Code Coverages(Cobertura)</name>
    </hudson.plugins.cobertura.dashboard.CoverageTablePortlet>
  </rightPortlets>*/
  // bottomPortlets {}
}
