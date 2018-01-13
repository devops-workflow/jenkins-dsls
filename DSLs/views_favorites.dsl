
listView('Test-Favorites') {
  description('Personal favorite jobs')
  configure { view ->
  //  view / icon(class: 'org.example.MyViewIcon')
    view / jobs(class: 'hudson.views.AllJobsFilter')
    view / jobs(class: 'hudson.plugins.favorite.filter.FavoriteFilter')
  }
  /*
  <jobFilters>
    <hudson.views.AllJobsFilter plugin="view-job-filters@1.27"/>
    <hudson.plugins.favorite.filter.FavoriteFilter plugin="favorite@2.3.1"/>
  </jobFilters>
  jobs {
    regex('Example-.*')
  }
  */
  columns {
    status ()
    weather ()
    name ()
    customIcon ()
    lastSuccess ()
    lastFailure ()
    lastDuration ()
    lastBuildConsole()
    buildButton ()
    //  <hudson.plugins.favorite.column.FavoriteColumn plugin="favorite@2.3.1"/>
    //  <hudson.plugins.projectstats.column.NumBuildsColumn plugin="project-stats-plugin@0.4"/>
  }
}
