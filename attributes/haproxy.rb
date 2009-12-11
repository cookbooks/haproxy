haproxy Mash.new unless attribute?(:haproxy)
haproxy[:user] = "app" unless haproxy.has_key?(:user)
haproxy[:group] = "app" unless haproxy.has_key?(:group)
haproxy[:instances] = [] unless haproxy.has_key?(:instances)
