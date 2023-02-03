/**
 * A filter procedure that gets the federation ID and updates the subject
 */
function result(context) {

    var attributes = context.attributeMap;
    var sub = attributes.subject;
    var indexOfAt = sub.indexOf('@');

    // federationId which will be sent to the external configuration source
    var federationId = indexOfAt >= 0 ? sub.substring(indexOfAt + 1) : 'default';

    var subject = indexOfAt >= 0 ? sub.substring(0, indexOfAt) : sub;

    // the dynamic authenticator will look at this attribute for the federation ID,
    // or use 'default' if it's not found.
    attributes['dynamic-authenticator-federation-id'] = federationId;
    attributes.subject = subject;

    return attributes;
}
