import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

// Set up initial admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def adminUsername = "admin"
def adminPassword = "admin"

// Only create the admin user if it doesn't exist already
if (hudsonRealm.getAllUsers().size() == 0) {
    hudsonRealm.createAccount(adminUsername, adminPassword)
    instance.setSecurityRealm(hudsonRealm)
    
    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    strategy.setAllowAnonymousRead(false)
    instance.setAuthorizationStrategy(strategy)
    
    instance.save()
    
    println "Jenkins initialized with admin user: ${adminUsername}"
    println "IMPORTANT: Please change the admin password as soon as possible!"
}

// Allow JNLP connections and slave agents
Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

// Disable upgrade wizard
if (instance.getUpdateCenter().isUsageStatisticsCollected()) {
    instance.getUpdateCenter().setUsageStatisticsCollected(false)
}