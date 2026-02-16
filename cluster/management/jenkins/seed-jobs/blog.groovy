#!/usr/bin/env groovy

pipelineJob('blog') {
    displayName('blog site')

    logRotator {
        numToKeep(100)
        daysToKeep(90)
    }

		properties {
        pipelineTriggers {
            triggers {
                pollSCM {
    							scmpoll_spec('H/5 * * * *')
								} 
            }
        }
    }

    configure { project ->
        project / 'properties' / 'org.jenkinsci.plugins.workflow.job.properties.DurabilityHintJobProperty' {
            hint('PERFORMANCE_OPTIMIZED')
        }
    }

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CaffeinatedOpe/blog')
                    }
                    branches('*/master')
                }
            }
            scriptPath('ci/Jenkinsfile')
        }
    }
}