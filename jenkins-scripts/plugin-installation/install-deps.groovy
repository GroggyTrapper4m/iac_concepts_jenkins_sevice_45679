import jenkins.model.*
import java.util.logging.Logger

def logger = Logger.getLogger("plugin-bootstrapper")
def pm = Jenkins.instance.pluginManager
def uc = Jenkins.instance.updateCenter
//Location within the Jenkins instance.
def pluginFile = new File("/var/jenkins_home/plugins.txt")

//Look for plugin file.
if (pluginFile.exists()) {
    pluginFile.eachLine { line ->
        //Adjust the name of the plugin for the console printout based on plugin-name and version number.
        //e.g. my-plugin:0.0.1
        def pluginName = line.trim().split(':')[0]
        if (pluginName && !pm.getPlugin(pluginName)) {
            logger.info(">>> Installing dependency: ${pluginName}")
            uc.getPlugin(pluginName).deploy()
        }
    }
    logger.info(">>> All dependencies queued. Restarting Jenkins to finalize...")