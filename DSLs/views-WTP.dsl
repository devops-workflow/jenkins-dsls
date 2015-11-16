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
  }
  columns {
    status ()
    weather ()
  }
}
