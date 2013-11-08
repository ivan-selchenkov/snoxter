module.exports = class ActionCollection extends Backbone.Collection
    model: require 'models/action_item'
    url: "#{CUST_SERVER}/scripts/v2/getact.cgi?uid=#{UID}&session=#{SESSION}&callback=?"
