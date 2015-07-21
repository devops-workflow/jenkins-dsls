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
    }
    nestedView('Pipelines') {
      description('Puppet Job Pipelines')
      views {
      }
    }
    listView('Templates') {
      description('Puppet Job Templates')
      jobs {
        regex('Puppet_Template_.*')
      }
    }
  }
}
