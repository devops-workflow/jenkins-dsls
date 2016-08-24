#!groovy
/*
  Auto create View tree structure for name spaced jobs

  Orgs/
     <org|name space>/		# Each organization | project team
                          # Support [A-Z0-9]
         <repo|job base name>/  # Each repo
             All jobs
             Branches ?
             Metrics
                All Jobs
             Workflows
*/
// TODO:
//  Add an application layer to the org tree. Between <org> and <repo>
//    Will need file to list top level application repos with dependencies that are not listed in code
//    Will need program to get deps from setup.py in all repos and build mapping table

def orgDescs = [
    'PRJ1'  : 'Project 1 description',
    'PRJ2'  : 'Project 2 description',
    'TEST'  : 'Testing jobs for implementing new things or verifing something is working',
    'REL'   : 'Release Engineering',
    'SRE'   : 'Site Reliability Engineering',
    'VERIFY': 'Automated jobs being tested to replace prior manual jobs'
]
// Job name pattern:
// <org>-<repo>_<function>_<function type>_<branch>
def jobFunctionRegex = 'analysis|package|validate'
def orgNameRegex     = '[A-Z][A-Z0-9]+'

// Get Org list
def getOrgs() {
  def jobs = hudson.model.Hudson.instance.items
  def orgs = [:]
  jobs.each { job ->
    // Processing all jobs
    // Build hash (map) of org names
    if (( m = job.name =~ /^([A-Z]+)-/ )) {
      orgs[m[0][1]] = 1
    }
  }
  orgs.keySet()
}

// Get base job names within an Org
def getOrgBaseJobs(org) {
  def jobs = hudson.model.Hudson.instance.items
  def baseNames = [:]
  //orgRegex = /^org/
  jobs.each { job ->
    // Processing all jobs
    // skip all jobs that do not start with org - Claim can only use in loop
    //if (( ! job.name =~ orgRegex )) continue
    // Build hash (map) of job base names
    if (( m = job.name =~ /^${org}-(.*)$/ )) {
      // got job name - org. Now strip to base
      // lowercase to be safe
      // Ends: NEED to define a solid standard
      //println "Job Match: ${m[0][1]}"
      if (( m1 = m[0][1] =~ /^(.*)_(analysis|package|validate)_/ )) {
        //println "\tBase Match: ${m1[0][1]}"
        baseNames[m1[0][1]] = 1
      } else {
        //println "\tBase Match: ${m[0][1]}"
        baseNames[m[0][1]] = 1
      }
    }
  }
  baseNames.keySet()
}

// Get jobs that can initiate a pipeline/workflow
// Currently the analysis jobs
def getPipelineInitialJobs(org, repo) {
  def jobs = hudson.model.Hudson.instance.items
  def baseNames = [:]
  //orgRegex = /^org/
  jobs.each { job ->
    // Processing all jobs
    // skip all jobs that do not start with org - Claim can only use in loop
    //if (( ! job.name =~ orgRegex )) continue
    // Build hash (map) of job base names
    if (( m = job.name =~ /^${org}-${repo}_analysis.*/ )) {
      // got job name - org.
      //println "Job Match: ${m[0]}"
      baseNames[m[0]] = 1
    }
  }
  baseNames.keySet()
}

def pipelineView (viewInst, project, desc, job) {
  viewInst.with {
    views {
      buildPipelineView(desc) {
        description("${project} ${desc} workflow")
        title("${project} ${desc}")
        displayedBuilds(10)
        refreshFrequency(60)
        //selectedJob("${project}-${job}")
        selectedJob(job)
        showPipelineDefinitionHeader()
      }
    }
  }
}

nestedView('Projects') {
  description('Automatically managed Project Team views')
  views {
    for (org in getOrgs()) {
      nestedView(org) {
        if (orgDescs.containsKey(org)) orgDesc = "${org}: ${orgDescs[org]}"
        else orgDesc = "${org} - long description not available"
        description(orgDesc)
        views {
          // ADD nested views per repo name (job base name)
          for (repo in getOrgBaseJobs(org)) {
            nestedView(repo) {
              description("${org} ${repo}")
              views {
                // all, branches, workflows, ...
                // categorizedJobsView for branches ?
                listView('All Jobs') {
                  description("All ${org} ${repo} Jobs")
                  jobs {
                    regex("${org}-${repo}.*")
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
                categorizedJobsView('By Branch') {
                  description("${org} ${repo} jobs by branch")
                  jobs {
                    regex(/${org}-${repo}.*/)
                  }
                  categorizationCriteria {
                    regexGroupingRule(/^[A-Z0-9]+-.+_(?:analysis|package|validate)_[A-Za-z]+_(.+)$/)
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
                categorizedJobsView('By Function') {
                  description("${org} ${repo} jobs by function")
                  jobs {
                    regex(/${org}-${repo}.*/)
                  }
                  categorizationCriteria {
                    regexGroupingRule(/^[A-Z0-9]+-.+_((?:analysis|package|validate)_[A-Za-z]+)_.+$/)
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
                nestedView('Metrics') {
                  description("${org} ${repo} Metrics")
                  views {
                    dashboardView('All Jobs') {
                      description("All ${org} ${repo} Jobs Metrics")
                      jobFilters {
                        regex {
                          matchType(MatchType.INCLUDE_MATCHED)
                          matchValue(RegexMatchValue.NAME)
                          regex("${org}-${repo}.*")
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
                      }
                      topPortlets {
                        jenkinsJobsList {
                          displayName("${org} ${repo} jobs")
                        }
                      }
                      bottomPortlets {}
                      leftPortlets {
                        buildStatistics {}
                      }
                      rightPortlets {
                        testStatisticsGrid {}
                        testTrendChart {
                          dateRange(14)
                        }
                        testStatisticsChart {}
                      }
                    }
                  }
                  columns {
                    status ()
                    weather ()
                  }
                }
                def workflowView = nestedView('Workflows') {
                  description("${org} ${repo} Workflows/Pipelines")
                  views {}
                  columns {
                    status ()
                    weather ()
                  }
                }
                // Add workflow views for all analysis jobs of this project
                for (job in getPipelineInitialJobs(org, repo)) {
                  // repo not sufficient for title need both function & type
                  if (( m = job =~ /^${org}-(${repo}_analysis_[^_]+).*/ )) {
                    workflowTitle = m[0][1]
                  } else {
                    workflowTitle = repo
                  }
                  pipelineView(workflowView, org, workflowTitle, job)
                }
              }
              columns {
                status ()
                weather ()
              }
            }
          }
        }
        columns {
          status ()
          weather ()
        }
      }
    }
  }
  columns {
    status ()
    weather ()
  }
}

/*
** END Org views
*/
