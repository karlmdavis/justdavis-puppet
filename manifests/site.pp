# Node-specific configuration goes into .pp definition files in /etc/puppet/manifests/nodes/.
# Note: Puppet will not automatically "catch" changes to these files. Run `sudo touch sudo touch /etc/puppet/manifests/site.pp` after creating/modifying the configuration for individual nodes.
import 'nodes/*.pp'

# The configuration here will be applied to all nodes.
# TODO
