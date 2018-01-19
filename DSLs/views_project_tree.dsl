#!groovy
/*
  Auto create View tree structure for name spaced jobs

  Create 2 trees: Environments, Projects

  Projects/
    <org|name space>/         # Each organization | project team
      All Jobs                # List of all jobs in organization
      All <env> Jobs          # List views of all jobs in each environment. Only env that exist for project
      ? All <function> jobs     # List views of all jobs per function. Only functions that exist for project
      <repo|job base name>/   # Each repo
        All jobs              # List of all jobs for the repo
        ? By Branches
        By Environment        # Categorize by infrastructure environment. Only env that exist for repo
        * By Function           # Categorize by function
        * By Tool               # Categorize by tool
        Metrics
          All Jobs
        Workflows
  Environments/
    <env name>/               # Each infrastructure environment
      All Jobs                # All jobs in infrastructure environment
      All <org> Jobs          # List views of all jobs in each organization
      ? All <function> jobs     # List views of all jobs per function in environment
      <repo|job base name>    # Each repo
        All Jobs              # List all jobs for the repo in the environment
        ? By Branch
        * By Function
        * By Tool
        Metrics
          All Jobs
        Workflows
*/
// TODO: Add test results column (format 2) for QA test job screens
//      testResult(2)
// FIX: Project view should only have environments that exist for that project
// FIX: Product by Env view filter. Add delimiter after repo. Acting as subset right now
//    Verify fix
// New views: Env tree - env X - functional views

def envDescs = [
    'CI'      : 'Continuous Integration'
    'Dev01'   : 'Dev01',
    'QA'      : 'QA',
    'Staging' : 'Staging',
    'Test'    : 'Dev/QA mixed use environment'
    'Prod'    : 'Production'
]
def orgDescs = [
    'PRJ1'  : 'Project 1 description',
    'PRJ2'  : 'Project 2 description',
    'DEVOP' : 'DevOps',
    'INFRASTRUCTURE' : 'Jobs for maintaining backend infrastructure',
    'JENKINS' : 'Jobs for mantaining Jenkins',
    'QA'      : 'Quality Assurance',
    'QE'      : 'Quality Engineering',
    'REL'     : 'Release Engineering',
    'SRE'     : 'Site Reliability Engineering',
    'TERRAFORM' : 'Terraform modules',
    'TEST'    : 'Testing jobs for implementing new things or verifing something is working',
    'UTIL'    : 'Utility task jobs. Tools, etc.',
    'VERIFY'  : 'Automated jobs being tested to replace prior manual jobs'
]
// OLD: Job name pattern:
// <org>-<repo>_<function>_<function type>_<branch>
// Change to support:
//  ?  <org><sep><repo><sep><function>
//  If 3rd field in envDescs, then
//    <org><sep><repo><sep><env><sep><function>
// Example:
//    TEST+repo+QA+Terraform_Plan
//  ?  TEST+repo+Analysis
// TODO: Change to support
//    <org><sep><repo><sep><env><sep><function|stage><sep><tool><sep><action|tool use|function type>
// Example:
//  ? TEST+repo+QA+Build+<lang & build tool>+Analysis
//  ? TEST+repo+QA+Build+<lang & build tool>+Package
//  ? TEST+repo+QA+Build+<lang & build tool>+Validate
//    TEST+repo+QA+Deploy+Terraform+Plan
//    TEST+repo+QA+Deploy+ECS
//    TEST+repo+QA+Test+ptest+<testSuite>
//    TEST+repo+QA+Perf+JMeter+<testPlan>

def jobFunctionRegex = 'analysis|package|validate' // TODO: remove
def orgNameRegex     = ~'[A-Z][A-Z0-9]+'
def separator        = '+='
def separatorRegex   = ~'[+=]'
def nameMinFieldsEnv = 4
def nameMinFieldsOrg = 3

// TODO: Need All env (env tree), Env per org (org tree), Env per Repo (org tree) NO - Category instead
// Get all or org environments list (qa, staging, prod)
// TODO: Change all calls to function
//def getEnvs(orgRegex, repoRegex, separators, minNameFields) {
def getEnvs(orgRegex, separators, minNameFields) {
  def jobs = hudson.model.Hudson.instance.items
  def envs = [:]
  for ( job in jobs ) {
    //jobs.each { job ->
    // Processing all jobs
    // 0: org, 1: repo(baseNames), 2: env, 3: function
    def jobNameParts = job.name.tokenize(separators)
    // Skip if not enough fields in the job name
    if (( jobNameParts.size() < minNameFields )) continue
    // Skip if not valid Org
    println "Testing org for getEnvs: ${jobNameParts[0]}"
    if (( "${jobNameParts[0]}" =~ /^$orgRegex$/ )) {
      // if (( "${jobNameParts[1]}" =~ /^$repoRegex$/ )) {
        // Build hash (map) of env names
        envs["${jobNameParts[2]}"] = 1
        println "Found Env: ${jobNameParts[2]}"
      //}
    }
  }
  println envs
  envs.keySet()
}
// Get base job names within an Environment (repo name)
def getEnvBaseJobs(env, separators, minNameFields) {
  def jobs = hudson.model.Hudson.instance.items
  def baseNames = [:]
  for ( job in jobs ) {
    // Processing all jobs
    // 0: org, 1: repo(baseNames), 2: env, 3: function
    def jobNameParts = job.name.tokenize(separators)
    // Skip if not enough fields in the job name
    if (( jobNameParts.size() < minNameFields )) continue
    // Skip if wrong env
    if (( "${jobNameParts[2]}" == env )) {
      // Build hash (map) of job base names
      // May need differ name: org+repo ?
      baseNames["${jobNameParts[1]}"] = 1
    }
  }
  baseNames.keySet()
}
// Get Org list (github organizations/gitlab groups)
def getOrgs(orgRegex, separators, minNameFields) {
  def jobs = hudson.model.Hudson.instance.items
  def orgs = [:]
  jobs.each { job ->
    // Processing all jobs
    // Why not getting global variables???
    def jobNameParts = job.name.tokenize(separators)
    // Skip if not enough fields in the job name
    if (( jobNameParts.size() >= minNameFields )) {
      // Build hash (map) of org names
      if (( "${jobNameParts[0]}" =~ /^$orgRegex$/ )) {
        orgs["${jobNameParts[0]}"] = 1
      }
    }
    //if (( m = job.name =~ /^($orgNameRegex)$separatorRegex/ )) {
    //  orgs[m[0][1]] = 1
    //}
  }
  orgs.keySet()
}

// Get base job names within an Org (repo name)
def getOrgBaseJobs(org, separators, minNameFields) {
  def jobs = hudson.model.Hudson.instance.items
  def baseNames = [:]
  //orgRegex = /^org/
  for ( job in jobs ) {
    // jobs.each { job ->
    // Processing all jobs
    // 0: org, 1: repo(baseNames), 2: env, 3: function
    // 0: org, 1: repo(baseNames), 2: function
    def jobNameParts = job.name.tokenize(separators)
    // Skip if not enough fields in the job name
    if (( jobNameParts.size() < minNameFields )) continue
    // Skip if correct Org
    if (( "${jobNameParts[0]}" != org )) continue

    // Build hash (map) of job base names
    baseNames["${jobNameParts[1]}"] = 1
    //if (( m = job.name =~ /^${org}-(.*)$/ )) {
    //  // got job name - org. Now strip to base
    //  // lowercase to be safe
    //  // Ends: NEED to define a solid standard
    //  //println "Job Match: ${m[0][1]}"
    //  if (( m1 = m[0][1] =~ /^(.*)_(analysis|package|validate)_/ )) {
    //    //println "\tBase Match: ${m1[0][1]}"
    //    baseNames[m1[0][1]] = 1
    //  } else {
    //    //println "\tBase Match: ${m[0][1]}"
    //    baseNames[m[0][1]] = 1
    //  }
    //}
  }
  baseNames.keySet()
}

// Get jobs that can initiate a pipeline/workflow
// Currently the analysis jobs
def getPipelineInitialJobs(org, repo, separators, minNameFields) {
  def jobs = hudson.model.Hudson.instance.items
  def baseNames = [:]
  //orgRegex = /^org/
  for ( job in jobs ) {
    //jobs.each { job ->
    // Processing all jobs
    // skip all jobs that do not start with org - Claim can only use in loop
    //if (( ! job.name =~ orgRegex )) continue
    // Build hash (map) of job base names
    // 0: org, 1: repo(baseNames), 2: env, 3: function
    def jobNameParts = job.name.tokenize(separators)
    // Skip if not enough fields in the job name
    if (( jobNameParts.size() < minNameFields )) continue
    // Skip if not correct Org
    if (( "${jobNameParts[0]}" != org )) continue
    // Skip if not correct Repo
    if (( "${jobNameParts[1]}" != repo )) continue

    // Build hash (map) of job base names
    // TODO: REDO
    //if (( "${jobNameParts[1]}" == repo )) {
    //  baseNames[] = 1
    //}

    // Find functions that start workflows
    //if (( m = job.name =~ /^${org}-${repo}_analysis.*/ )) {
    // TODO: Build env list from envDescs - Remove hard code in regex
    if (( m = job.name =~ /^${org}[${separators}]${repo}[${separators}](?:QA|Staging|Prod)[${separators}]Deploy[${separators}]Terraform[${separators}]Plan/ )) {
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


nestedView('Environments') {
  description('Automatically managed Environment views')
  views {
    //for (env in getEnvs(orgNameRegex, '.*', separator, nameMinFieldsEnv)) {
    for (env in getEnvs(orgNameRegex, separator, nameMinFieldsEnv)) {
      nestedView(env) {
        if (envDescs.containsKey(env)) envDesc = "${env}: ${envDescs[env]}"
        else envDesc = "${env} - long description not available"
        description(envDesc)
        views {
          // Add All jobs in environment view
          listView('All Jobs') {
            description("All ${env} Jobs")
            jobs {
              regex(".*[${separator}]${env}[${separator}].*")
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
          // All Jobs By Function
          categorizedJobsView('All Jobs By Function') {
            description("All ${env} jobs by function")
            jobs {
              regex(/.*[${separator}]${env}[${separator}].*/)
            }
            categorizationCriteria {
              regexGroupingRule(/^[^${separator}]+[${separator}][^${separator}]+[${separator}]${env}[${separator}]([^${separator}]+).*$/)
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
          // Add organization views for each env - List all that match org & env
          for (org in getOrgs(orgNameRegex, separator, nameMinFieldsOrg)) {
            listView("All ${org} Jobs") {
              description("All ${org} jobs in ${env}")
              jobs {
                regex("${org}[${separator}].*[${separator}]${env}[${separator}].*")
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
          }
          // ADD nested views per environment name
          for (repo in getEnvBaseJobs(env, separator, nameMinFieldsEnv)) {
            nestedView(repo) {
              description("${env} ${repo}")
              views {
                // all, branches, workflows, ...
                // categorizedJobsView for branches ?
                listView('All Jobs') {
                  description("All ${env} ${repo} Jobs")
                  jobs {
                    regex(".*${repo}[${separator}]${env}.*")
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
                  description("${env} ${repo} jobs by branch")
                  jobs {
                    regex(/.*${repo}[${separator}]${env}.*/)
                  }
                  categorizationCriteria {
                    // Fix: when decide on branch naming
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
                  description("${env} ${repo} jobs by function")
                  jobs {
                    regex(/.*${repo}[${separator}]${env}.*/)
                  }
                  categorizationCriteria {
                    regexGroupingRule(/^[^${separator}]+[${separator}]${repo}[${separator}]${env}[${separator}]([^${separator}]+).*$/)
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
                  description("${env} ${repo} Metrics")
                  views {
                    dashboardView('All Jobs') {
                      description("All ${env} ${repo} Jobs Metrics")
                      jobFilters {
                        regex {
                          matchType(MatchType.INCLUDE_MATCHED)
                          matchValue(RegexMatchValue.NAME)
                          regex(".*${repo}[${separator}]${env}.*")
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
                          displayName("${env} ${repo} jobs")
                        }
                      }
                      bottomPortlets {}
                      leftPortlets {
                        buildStatistics {
                          displayName('Build Statistics')
                        }
                      }
                      rightPortlets {
                        testStatisticsChart{
                          displayName('Test Statistics Chart')
                        }
                        testStatisticsGrid {
                          displayName('Test Statistics Grid')
                        }
                        testTrendChart {
                          displayName('Test Trend Chart')
                          displayStatus(DisplayStatus.ALL)
                          dateRange(14)
                          graphHeight(220)
                          graphWidth(300)
                        }
                      }
                    }
                  }
                  columns {
                    status ()
                    weather ()
                  }
                }
                def workflowView = nestedView('Workflows') {
                  description("${env} ${repo} Workflows/Pipelines")
                  views {}
                  columns {
                    status ()
                    weather ()
                  }
                }
                // Add workflow views for all analysis jobs of this project
                //for (job in getPipelineInitialJobs(org, repo, separator, nameMinFieldsOrg)) {
                //  // repo not sufficient for title need both function & type
                // ^${org}${separator}${repo}${separator}QA${separator}Deploy${separator}Terraform${separator}Plan
                //  if (( m = job =~ /^${org}[+=](${repo}_analysis_[^_]+).*/ )) {
                //    workflowTitle = m[0][1]
                //  } else {
                //    workflowTitle = repo
                //  }
                //  pipelineView(workflowView, org, workflowTitle, job)
                //}
              }
              columns {
                status ()
                weather ()
              }
            }
          }
        } // END views
        columns {
          status ()
          weather ()
        }
      }
    }
  } // END views
  columns {
    status ()
    weather ()
  }
} // END Enviroments view tree

nestedView('Projects') {
  description('Automatically managed Project Team views. These match the gitlab organization')
  views {
    for (org in getOrgs(orgNameRegex, separator, nameMinFieldsOrg)) {
      nestedView(org) {
        if (orgDescs.containsKey(org)) orgDesc = "${org}: ${orgDescs[org]}"
        else orgDesc = "${org} - long description not available"
        description(orgDesc)
        views {
          // Add All jobs in organization view
          listView('All Jobs') {
            description("All ${org} Jobs")
            jobs {
              regex("${org}[${separator}].*")
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
          // Add environment views for each org - List all that match org & env
          //for (env in getEnvs(org, '.*', separator, nameMinFieldsEnv)) {
          for (env in getEnvs(orgNameRegex, separator, nameMinFieldsEnv)) {
            listView("All ${env} Jobs") {
              description("All ${env} jobs for ${org}")
              jobs {
                regex("${org}[${separator}].*[${separator}]${env}[${separator}].*")
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
          }
          // Add nested views per repo name (job base name)
          for (repo in getOrgBaseJobs(org, separator, nameMinFieldsOrg)) {
            nestedView(repo) {
              description("${org} ${repo}")
              views {
                // all, branches, workflows, ...
                // categorizedJobsView for branches ?
                listView('All Jobs') {
                  description("All ${org} ${repo} Jobs")
                  jobs {
                    regex("${org}[${separator}]${repo}[${separator}].*")
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
                    regex(/${org}[${separator}]${repo}[${separator}].*/)
                  }
                  categorizationCriteria {
                    // FIX: once branch naming decided on
                    regexGroupingRule(/^${org}[${separator}]${repo}.+_(?:analysis|package|validate)_[A-Za-z]+_(.+)$/)
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
                categorizedJobsView('By Environment') {
                  description("${org} ${repo} jobs by environment")
                  jobs {
                    regex(/${org}[${separator}]${repo}[${separator}].*/)
                  }
                  categorizationCriteria {
                    regexGroupingRule(/^${org}[${separator}]${repo}[${separator}]([^${separator}]+).+$/)
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
                    regex(/${org}[${separator}]${repo}[${separator}].*/)
                  }
                  categorizationCriteria {
                    regexGroupingRule(/^${org}[${separator}]${repo}[${separator}][^${separator}]+[${separator}]([^${separator}]+).*$/)
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
                          regex("${org}[${separator}]${repo}[${separator}].*")
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
                        buildStatistics {
                          displayName('Build Statistics')
                        }
                      }
                      rightPortlets {
                        testStatisticsChart{
                          displayName('Test Statistics Chart')
                        }
                        testStatisticsGrid {
                          displayName('Test Statistics Grid')
                        }
                        testTrendChart {
                          displayName('Test Trend Chart')
                          displayStatus(DisplayStatus.ALL)
                          dateRange(14)
                          graphHeight(220)
                          graphWidth(300)
                        }
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
                for (job in getPipelineInitialJobs(org, repo, separator, nameMinFieldsOrg)) {
                  // repo not sufficient for title need both function & type
                  // TODO: maybe use metadata to tag pipeline starts. Then build from that.
                  // ^${org}${separator}${repo}${separator}QA${separator}Deploy${separator}Terraform${separator}Plan
                  //if (( m = job =~ /^${org}[${separator}](${repo}_analysis_[^_]+).*/ )) {
                  if (( m = job =~ /^${org}[${separator}](${repo}[${separator}](?:QA|Staging|Prod)[${separator}]Deploy[${separator}]Terraform[${separator}]Plan)/ )) {
                    workflowTitle = m[0][1]
                  } else {
                    workflowTitle = repo
                  }
                  pipelineView(workflowView, org, workflowTitle, job)
                  if (( m = job =~ /^${org}[${separator}](${repo}[${separator}](?:CI|QA|Staging|Prod)[${separator}]Analytics[${separator}]CircleCI)/ )) {
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
        } // END views
        columns {
          status ()
          weather ()
        }
      }
    }
  } // END views
  columns {
    status ()
    weather ()
  }
} // END Projects view tree

/*
** END Org views
*/
