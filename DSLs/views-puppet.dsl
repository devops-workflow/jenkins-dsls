nestedView('Puppet-DSL') {
  description('Everything related to Cloud Operations Puppet')
  views {
    nestedView('Metrics') {
      description('Puppet Job Metrics')
      views {
      }
    }
    listView('Puppet') {
      description('Misc Puppet Jobs')
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
    listView('Puppet Control') {
      description('Puppet control (r10k) branch jobs')
      jobFilters {
        regex {
          matchType(MatchType.INCLUDE_MATCHED)
          matchValue(RegexMatchValue.NAME)
          regex('Puppet_Control-.*')
        }
        regex {
          matchType(MatchType.EXCLUDE_MATCHED)
          matchValue(RegexMatchValue.NAME)
          regex('.*Template.*')
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
    }
    listView('Puppet Modules') {
      description('Puppet module jobs')
      jobFilters {
        regex {
          matchType(MatchType.INCLUDE_MATCHED)
          matchValue(RegexMatchValue.NAME)
          regex('Puppet_Module_.*')
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
    }
    categorizedJobsView('Categories') {
      description('Puppet Job Categories')
      jobFilters {
        regex {
          matchType(MatchType.INCLUDE_MATCHED)
          matchValue(RegexMatchValue.NAME)
          regex('Puppet_.*')
        }
      }
      categorizationCriteria {
        regexGroupingRule('Puppet_(Module|Template)_(.*)','Puppet $1')
      }
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
    nestedView('Pipelines') {
      description('Puppet Job Pipelines')
      views {
      }
    }
    listView('Templates') {
      description('Puppet Job Templates')
      jobs {
        regex('Puppet.*[_-]Template(_.*|$)')
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
