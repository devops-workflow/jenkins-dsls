nestedView('Jenkins-DSL') {
  description('Everything related to Jenkins itself')
  views {
    listView('Jenkins') {
      description('Jenkins Maintenance Jobs')
      jobs {
        regex('Jenkins_.*')
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
      description('Jenkins Metrics')
      views {
      }
    }
    listView('Templates') {
      description('Generic Templates')
      jobs {
        regex('Template[-_].*')
      }
      columns {
        name ()
      }
    }
  }
  columns {
    status ()
    weather ()
  }
}
